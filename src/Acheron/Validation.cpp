#include "Acheron/Validation.h"

#include "Util/FormLookup.h"
#include "Util/Misc.h"

namespace Acheron
{
	void Validation::Initialize()
	{
		logger::info("Loading Exclusion Data");
		const auto exclusionpath = CONFIGPATH("Validation");
		if (!fs::exists(exclusionpath)) {
			logger::warn("Exclusion path does not exist: {}", exclusionpath);
			return;
		}
		const auto parseList = [](const YAML::Node& a_node, const Conditions::RefMap& refs, auto& a_list) {
			if (!a_node.IsDefined() || !a_node.IsSequence())
				return;

			for (const auto& item : a_node) {
				Conditions::Conditional conditional;
				std::string formIdStr;

				if (item.IsScalar()) {
					formIdStr = item.as<std::string>();
					conditional = {};
				} else if (item.IsMap() && item["FormID"]) {
					formIdStr = item["FormID"].as<std::string>();
					conditional = {
						a_node["Conditions"].as<std::vector<std::string>>(std::vector<std::string>{}),
						refs
					};
				} else {
					logger::warn("Invalid exclusion entry format; skipping");
					continue;
				}

				const auto id = refs.LookupId(formIdStr);
				if (id != 0 || formIdStr == "0"s) {
					a_list.emplace_back(id, conditional);
				} else {
					logger::warn("Cannot exclude '{}'. Form does not exist or associated file not loaded", formIdStr);
				}
			}
		};
		const auto readBranch = [&](const YAML::Node& a_branch, const Conditions::RefMap& refs, VTarget a_validation) {
			if (!a_branch.IsDefined())
				return;
			parseList(a_branch["ActorBase"], refs, exclNPC[a_validation]);
			parseList(a_branch["Reference"], refs, exclRef[a_validation]);
			parseList(a_branch["Race"], refs, exclRace[a_validation]);
			parseList(a_branch["Faction"], refs, exclFaction[a_validation]);
		};
		for (auto& file : fs::directory_iterator{ exclusionpath }) {
			try {
				const auto filepath = file.path().string();
				if (!filepath.ends_with(".yaml") && !filepath.ends_with(".yml"))
					continue;
				logger::info("Reading file {}", filepath);
				const auto root{ YAML::LoadFile(filepath) };
				const auto refs = root["refMap"].as<std::map<std::string, std::string>>(std::map<std::string, std::string>{});
				const Conditions::RefMap refMap{ refs };
				parseList(root["LocationA"], refs, exclLocAll);
				parseList(root["LocationT"], refs, exclLocTp);
				parseList(root["MagicEffect"], refs, exclMagicEffect);

				readBranch(root["Assailant"], refs, VTarget::Assailant);
				readBranch(root["Victim"], refs, VTarget::Victim);
				readBranch(root, refs, VTarget::Either);
				logger::info("Added exclusion data from file {}", filepath);
			} catch (const std::exception& e) {
				logger::error("{}", e.what());
			}
		}
		logger::info("Finished loading Exclusion Data");
	}

	bool ExclusionData::IsExcluded(RE::FormID a_targetID, RE::TESObjectREFR* a_conditionRef) const
	{
		if (formID == 0 && conditional) {
			return conditional.ConditionsMet(a_conditionRef, a_conditionRef);
		}
		bool formIdMatch = a_targetID != formID;
		bool conditionMatch = (!conditional || conditional.ConditionsMet(a_conditionRef, a_conditionRef));
		return formIdMatch && conditionMatch;
	}

	bool Validation::CanProcessDamage()
	{
		if (!Settings::ProcessingEnabled) {
			return false;
		}

		const auto player = RE::PlayerCharacter::GetSingleton();
		if (const auto loc = player->GetCurrentLocation()) {
			return std::ranges::none_of(exclLocAll, [&](const ExclusionData& locData) {
				return locData.IsExcluded(loc->formID, player);
			});
		}

		return true;
	}

	bool Validation::ValidatePair(RE::Actor* a_victim, RE::Actor* a_aggressor)
	{
		if (a_victim->IsDead() || a_victim->IsInKillMove())
			return false;
		if (a_victim->IsPlayerRef()) {
			if (!Settings::bPlayerDefeat) {
				return false;
			}
		} else if (a_victim->IsPlayerTeammate()) {
			if (!Settings::bFollowerDefeat) {
				return false;
			}
		} else if (a_aggressor) {
			if (!UsesHunterPride(a_aggressor) && (!Settings::bNPCDefeat || !a_victim->IsHostileToActor(a_aggressor)))
				return false;
			if (auto ref = a_victim->GetObjectReference(); ref && ref->As<RE::BGSKeywordForm>()->HasKeywordID(0xD205E))	 // ActorTypeGhost
				return false;
		} else if (!Settings::bNPCDefeat) {
			return false;
		}
		if (a_aggressor) {
			if (a_aggressor->IsDead() || a_aggressor->IsInKillMove())
				return false;
			if (!Settings::bCreatureDefeat && !IsNPC(a_aggressor))
				return false;
			if (!CheckExclusion(VTarget::Assailant, a_aggressor))
				return false;
		}
		return CheckExclusion(VTarget::Victim, a_victim);
	}

	bool Validation::AllowRescueEffect(RE::EffectSetting* a_effect)
	{
		const auto player = RE::PlayerCharacter::GetSingleton();
		return std::ranges::none_of(exclMagicEffect, [&](const ExclusionData& effectData) {
			return effectData.IsExcluded(a_effect->formID, player);
		});
	}

	bool Validation::AllowDetrimentalEffect(RE::EffectSetting* a_effect)
	{
		return !AllowRescueEffect(a_effect);
	}

	bool Validation::AllowTeleport()
	{
		const auto player = RE::PlayerCharacter::GetSingleton();
		if (player->GetCurrentScene() != nullptr) {
			return false;
		}

		if (const auto loc = player->GetCurrentLocation()) {
			return std::ranges::none_of(exclLocTp, [&](const ExclusionData& locData) {
				return locData.IsExcluded(loc->formID, player);
			});
		}

		return true;
	}

	bool Validation::CheckExclusion(VTarget a_validation, RE::Actor* a_actor)
	{
		const auto isAllowed = [&](RE::FormID a_id, const auto a_list[3]) -> bool {
			const auto f = [&](const ExclusionData& data) {
				return data.IsExcluded(a_id, a_actor);
			};
			return std::ranges::none_of(a_list[VTarget::Either], f) && std::ranges::none_of(a_list[a_validation], f);
		};
		if (!isAllowed(a_actor->GetFormID(), exclRef)) {
			return false;
		}
		const auto base = Util::GetLeveledActorBase(a_actor);
		if (base && !isAllowed(base->GetFormID(), exclNPC)) {
			return false;
		}
		const auto race = a_actor->GetRace();
		if (race && !isAllowed(race->GetFormID(), exclRace)) {
			return false;
		}
		// visitor returns true on the first iteration that returns true, false otherwise
		return !a_actor->VisitFactions([&](RE::TESFaction* faction, uint8_t rank) {
			if (!faction || rank < 0)
				return false;

			return !isAllowed(faction->formID, exclFaction);
		});
	}

}  // namespace Acheron
