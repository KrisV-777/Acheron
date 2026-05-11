---
title: Papyrus API
nav_order: 5
---

# Papyrus API

This page documents the Papyrus functions and event registration helpers currently exposed by the plugin.  

The public API can be found in `Acheron.psc`. 

## Status Functions

| Function | Behavior |
|---|---|
| `DisableProcessing(bool disable)` | Toggles processing globally (`true` disables). When disabling, Hunter Pride spell is removed from player if present. |
| `DisableConsequence(bool disable)` | Toggles consequence events globally (`true` disables). |
| `IsProcessingDisabled()` | Returns current processing-disabled state. |
| `IsConsequenceDisabled()` | Returns current consequence-disabled state. |
| `IsTeleportAllowed()` | Returns current teleport allowance from validation. |

## Defeat Functions

| Function | Behavior |
|---|---|
| `DefeatActor(Actor actor)` | Queues a task to defeat actor. No-op with trace error if actor is `None`. |
| `RescueActor(Actor actor, bool undoPacify)` | Queues a task to rescue actor. No-op with trace error if actor is `None`. |
| `PacifyActor(Actor actor)` | Applies pacify state immediately. |
| `ReleaseActor(Actor actor)` | Removes pacify state immediately. |
| `IsDefeated(Actor actor)` | Returns defeat state for actor. |
| `IsPacified(Actor actor)` | Returns pacify state for actor. |
| `GetDefeated(bool loadedOnly)` | Returns defeated actor array. |
| `GetPacified(bool loadedOnly)` | Returns pacified actor array. |

## Hunter Pride Functions

### Options

| Function | Behavior |
|---|---|
| `AddOption(string id, string name, string iconPath, string conditionJson)` | Adds custom option. Returns option ID or `-1` on failure. Condition JSON is lowercased before parse. |
| `RemoveOption(string id)` | Removes custom option by ID. |
| `HasOption(string id)` | Checks whether option exists. |
| `GetOptionID(string id)` | Resolves option ID (`0..3` for built-ins, custom start at `4`). |

## Utility Functions

| Function | Behavior |
|---|---|
| `PrintConsole(string message)` | Prints message to game console. |
| `OpenCustomMenu(string swfPathWithoutExt)` | Opens custom menu from `Data/Interface/<path>.swf`. Returns false if invalid path, file missing, or menu already open. |
| `CloseCustomMenu()` | Closes custom menu (non-VR). |

## Actor Helper Functions

| Function | Behavior |
|---|---|
| `GetWornArmor(Actor actor, int ignoredMasks)` | Returns worn armor list. |
| `StripActor(Actor actor, int ignoredMasks)` | Unequips armor (except `NoStrip` keyword) and returns removed pieces. |
| `GetMostEfficientPotion(Actor actor, ObjectReference container)` | Returns best health potion candidate from container. |
| `GetFollowers()` | Returns follower actor list. |
| `GetRaceType(Actor actor)` | Returns race type string used by consequence conditions. |

## Object Reference Functions

| Function | Behavior |
|---|---|
| `SetLinkedRef(ObjectReference object, ObjectReference target, Keyword keyword)` | Sets linked ref on source object. |
| `GetItemsByKeywords(ObjectReference container, Keyword[] keywords, int minValue, bool includeQuestItems)` | Returns forms matching filters. |
| `RemoveAllItems(ObjectReference from, ObjectReference to, bool excludeWorn)` | Moves/removes items with runtime reason based on target type. |

## Event Registration

Registration helpers require a non-None receiver object. If receiver is `None`, registration traces and no-ops.

### Actor Defeated

- `RegisterForActorDefeated(Form receiver)`
- `UnregisterForActorDefeated(Form receiver)`
- `RegisterForActorDefeated_Alias(ReferenceAlias receiver)`
- `UnregisterForActorDefeated_Alias(ReferenceAlias receiver)`
- `RegisterForActorDefeated_MgEff(ActiveMagicEffect receiver)`
- `UnregisterForActorDefeated_MgEff(ActiveMagicEffect receiver)`

### Actor Rescued

- `RegisterForActorRescued(Form receiver)`
- `UnregisterForActorRescued(Form receiver)`
- `RegisterForActorRescued_Alias(ReferenceAlias receiver)`
- `UnregisterForActorRescued_Alias(ReferenceAlias receiver)`
- `RegisterForActorRescued_MgEff(ActiveMagicEffect receiver)`
- `UnregisterForActorRescued_MgEff(ActiveMagicEffect receiver)`

### Hunter Pride Selection

- `RegisterForHunterPrideSelect(Form receiver)`
- `UnregisterForHunterPrideSelect(Form receiver)`
- `RegisterForHunterPrideSelect_Alias(ReferenceAlias receiver)`
- `UnregisterForHunterPrideSelect_Alias(ReferenceAlias receiver)`
- `RegisterForHunterPrideSelect_MgEff(ActiveMagicEffect receiver)`
- `UnregisterForHunterPrideSelect_MgEff(ActiveMagicEffect receiver)`

## Example: Custom Hunter Pride Option

```papyrus
Event OnInit()
    int optionID = Acheron.AddOption(
        "MyOption",
        "$MyOptionName",
        "Interface\\Acheron\\MyOption.dds",
        "{\"target\":{\"is\":[\"nonessential\"]}}"
    )

    if optionID >= 0
        Acheron.RegisterForHunterPrideSelect(self)
    endif
EndEvent

Event OnHunterPrideSelect(int aiOptionID, Actor akTarget)
    if aiOptionID == Acheron.GetOptionID("MyOption")
        Debug.Trace("My option selected")
    endif
EndEvent
```

## Notes

- Passing empty option IDs to option helpers traces and fails.
- Most actor/object functions trace and return safe defaults when passed `None`.
- `OpenCustomMenu` is not available in VR builds.

## Last Updated

May 2026
