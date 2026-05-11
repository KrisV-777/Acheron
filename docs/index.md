---
title: Home
nav_order: 1
---

# Acheron

**Acheron** is an SKSE64 plugin for Skyrim Special Edition that replaces vanilla death flow with a configurable defeat system.

When a lethal hit would happen, Acheron can keep the actor alive in a defeat state and run a custom consequence event.

## What You Can Do

- **Add consequence events** with YAML files
- **Define when events trigger** by assailant, victim, quest state, location, and more
- **Interact with defeated NPCs** through the Hunter Pride menu
- **Customize Hunter Pride actions** with your own options and conditions
- **Protect fragile quests/locations** with validation rules

## How It Works

Acheron loads event and validation files from SKSE data folders and evaluates them at runtime.

```text
Data/SKSE/Acheron/Consequences/
Data/SKSE/Acheron/Validation/
```

At runtime it:

1. Detects lethal damage
2. Validates whether defeat handling is allowed
3. Picks a matching event by priority/conditions
4. Applies defeat state and starts the event quest

## Pages

- [Events](Events.md)
- [Hunter Pride](Hunter-Pride.md)
- [Validation](Validation.md)
- [Papyrus API](Papyrus-API.md)
- [Developer Guide](Developer-Guide.md)

## Notes

- All Configuration Files use `.yml` or `.yaml`.
- Event file extension and field validation are strict.
- Event weights are loaded from `Data/SKSE/Acheron/Consequences/Weights.yaml`.

## Last Updated

May 2026
