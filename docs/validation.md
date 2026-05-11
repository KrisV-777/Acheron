---
title: Validation
nav_order: 4
---

# Validation

Validation controls when Acheron is allowed to process defeat logic, teleport events, and rescue-effect behavior.

## File Location

Validation files are loaded from:

```text
Data/SKSE/Acheron/Validation/
```

Only `.yml` and `.yaml` files are read.

## What Validation Affects

- Damage processing in current location (`LocationA` + processing toggle)
- Teleport allowance (`LocationT` + scene check)
- Which actors can be defeated (reference/base/race/faction exclusions)
- Which magic effects are allowed to rescue/defeat actors (`MagicEffect`)

## Top-Level YAML Shape

```yaml
refMap: {}

LocationA: []
LocationT: []
MagicEffect: []

Reference: []
ActorBase: []
Race: []
Faction: []

Assailant:
  Reference: []
  ActorBase: []
  Race: []
  Faction: []

Victim:
  Reference: []
  ActorBase: []
  Race: []
  Faction: []
```

Important:

- Root `Reference/ActorBase/Race/Faction` apply to both sides (assailant and victim).
- `Assailant` and `Victim` branches add side-specific exclusions.

## Entry Formats

Each exclusion list supports two entry formats.

### 1. Scalar form entry

```yaml
LocationT:
  - 0x00018C91
```

### 2. Form + Conditions entry

```yaml
ActorBase:
  - FormID: 0x0001327E
    Conditions:
      - GetQuestRunning 0x00096E71 == 1 AND
```

Rules:

- `Conditions` is optional.
- If `FormID` is `0` with conditions, the conditions are applied to every object.
  - A `FormID` field with `0` value is invalid if no conditon is present. 
- Invalid entries are skipped.

## refMap Support

`refMap` is supported in this file and is used during ID resolution.

```yaml
refMap:
  player: Player
  myBoss: 0x801|MyMod.esp
```

Then aliases can be used in `FormID` and condition arguments.

## Practical Example

```yaml
refMap:
  myDungeon: 0x123|MyMod.esp

LocationA:
  - myDungeon

LocationT:
  - FormID: 0
    Conditions:
      - GetStage 0x0003372B > 250 AND
      - GetStage 0x0003372B < 1000 OR

ActorBase:
  - 0x0003C57C

Assailant:
  ActorBase:
    - 0x00034D97

Victim:
  ActorBase:
    - FormID: 0x0001327A
      Conditions:
        - GetQuestRunning 0x0001EA54 == 1 AND

MagicEffect:
  - 0x000B8780
```

## Runtime Notes

- `CanProcessDamage()` fails if processing is disabled or current location matches `LocationA`.
- `AllowTeleport()` fails if player is currently in a scene or location matches `LocationT`.
- `AllowRescueEffect()` fails if effect matches `MagicEffect`; detrimental effects are the inverse check.
- Actor exclusion checks evaluate reference, actor base, race, and faction against root + side-specific lists.

## Built-In Defaults

The mod ships with a default file at:

```text
dist/SKSE/Acheron/Validation/Acheron.yml
```

Use that file as the canonical example for real-world rules and conditional patterns.

## Common Mistakes

- Using map entries like `FormID: Victim` (not supported)
- Forgetting list format (`- item`) for exclusion branches
- Using non-existent form strings without loading required plugins

## Last Updated

May 2026
