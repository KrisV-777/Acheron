#pragma once
namespace Acheron
{
	// Actor
	bool HasBeneficialPotion(RE::TESObjectREFR* a_container);
	float GetAVPercent(RE::Actor* a_actor, RE::ActorValue a_av);
	std::vector<RE::TESObjectARMO*> GetWornArmor(RE::Actor* a_actor, uint32_t a_ignoredmasks = 0);
	std::vector<RE::Actor*> GetFollowers();

	bool IsHunter(RE::Actor* a_actor);
	bool UsesHunterPride(const RE::Actor* a_actor);
	bool IsNPC(const RE::Actor* a_actor);
	bool IsDaedric(const RE::TESForm* a_form);

}	 // namespace Acheron
