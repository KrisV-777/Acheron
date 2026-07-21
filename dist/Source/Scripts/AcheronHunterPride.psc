Scriptname AcheronHunterPride extends Quest Hidden 

Function OpenHunterPrideMenu(Actor akTarget) native

AcheronMCM Property MCM Auto

PlayerVampireQuestScript Property PlayerVampireQuest Auto
Activator Property HealTargetFX Auto
Actor Property PlayerRef Auto
Idle Property pa_HugA Auto

Faction Property ExecuteFaction  Auto  
Message Property IsEssentialMsg Auto
Message Property NoPotionMsg Auto

Function OpenMenu(Actor akTarget)
  Acheron.RegisterForHunterPrideSelect(self)
  OpenHunterPrideMenu(akTarget)
EndFunction

Event OnHunterPrideSelect(int aiOptionID, Actor akTarget)
  Debug.Trace("[Acheron] OnHunterPrideSelect: " + aiOptionID + " / " + akTarget)
  If(aiOptionID == 0)
    Potion p = Acheron.GetMostEfficientPotion(akTarget, PlayerRef)
    If(!p)
      NoPotionMsg.Show()
      return
    EndIf
    PlayerRef.RemoveItem(p, 1, true, akTarget)
    akTarget.EquipItem(p, false, true)
    If(Acheron.IsDefeated(akTarget))
      ; Some actors are immune to potion effect
      akTarget.PlaceAtMe(HealTargetFX)
      akTarget.RestoreActorValue("Health", 25.0)
      Acheron.RescueActor(akTarget, true)
    EndIf
  ElseIf(aiOptionID == 1)
    akTarget.OpenInventory(true)
    akTarget.SendAssaultAlarm()
  ElseIf(aiOptionID == 2)
    If(CheckEssential(akTarget))
      return
    EndIf

    akTarget.AddToFaction(ExecuteFaction)
    PlayerRef.AddToFaction(ExecuteFaction)
    If (SKSE.GetPluginVersion("OpenAnimationReplacer") == -1 || SKSE.GetPluginVersion("PairedAnimationImprovements") == -1)
      String errMsg = "'OpenAnimationReplacer' or 'PairedAnimationImprovements' not detected, skipping animation"
      Debug.Trace("[Acheron] " + errMsg)
      Debug.MessageBox(errMsg)
      akTarget.Kill(PlayerRef)
    ElseIf (!MCM.GetSettingBool("bHunterPrideKillAnim"))
      akTarget.Kill(PlayerRef)
    Else
      Game.ForceThirdPerson()
      akTarget.SetHeadTracking(false)
      PlayerRef.SetHeadTracking(false)
      Float zOffset = PlayerRef.GetHeadingAngle(akTarget)
      PlayerRef.SetAngle(0.0, 0.0, PlayerRef.GetAngleZ() + zOffset)
      Utility.Wait(0.1)
      If PlayerRef.IsWeaponDrawn()
          PlayerRef.SheatheWeapon()
          Float i = 3.0
          While (PlayerRef.IsWeaponDrawn() && (i > 0.0))
              Utility.Wait(0.1)
              i -= 0.1
          EndWhile
      Endif
      Debug.SendAnimationEvent(akTarget, "IdleForceDefaultState")
      PlayerRef.playIdleWithTarget(pa_HugA, akTarget)
      PlayerRef.SetHeadTracking(true)
    EndIf
    PlayerRef.RemoveFromFaction(ExecuteFaction)
  ElseIf(aiOptionID == 3)
    If(CheckEssential(akTarget))
      return
    EndIf
    PlayerRef.StartVampireFeed(akTarget)
    PlayerVampireQuest.VampireFeed()
    akTarget.Kill(PlayerRef)
  EndIf
EndEvent

bool Function CheckEssential(Actor akTarget)
  ActorBase base = akTarget.GetLeveledActorBase()
  If(!base.IsEssential())
    return false
  EndIf
  If(IsEssentialMsg.Show() == 1)
    base.SetEssential(false)
    return false
  EndIf
  return true
EndFunction
