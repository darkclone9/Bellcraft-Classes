# NOTES.md – MythicLib Skill Integration into MMOCore Classes

## Branch
`feature/mmocore-mythiclib-skills`

## What Changed

### 1. Skill Tree Fixes & Additions

#### `MMOCore/skill-trees/cleric-divinity.yml` – **FIXED**
The tree previously had a placeholder comment (`# ... [Keep your existing a1 through g3 nodes here] ...`) instead of real stat nodes, which caused MMOCore to fail loading the tree (skill unlock nodes referenced non-existent parents `a3`, `c2`, `d1`, `e3`, `f1`).
- Added full set of stat nodes: Healing Power, Divine Devotion, Mana Flow, Life Renewal, Divine Shield, Sacred Vitality, Grace (a1–g3)
- Changed skill unlock nodes to `root: true` (independent, no parents required) to keep them accessible

#### Trees with new Skill Unlock Nodes added
Each tree now has `root: true` skill unlock nodes (no prerequisites) at the edges so players can spend skill-tree points to unlock abilities:

| Tree | New Skill Unlock Nodes |
|------|------------------------|
| `soldier` | SOLDIER_SHIELD_BASH, SOLDIER_WARRIORS_LEAP, SOLDIER_BATTLE_CRY, COMBAT_STANCE, SUPPRESSING_FIRE, TACTICAL_RELOAD |
| `operative` | OPERATIVE_SHADOW_STRIKE, OPERATIVE_POISON_BLADE, OPERATIVE_VANISH, TRICK_ATTACK, EVASION_PROTOCOL |
| `ranger-hunter` | RANGER_EXPLOSIVE_ARROW, RANGER_CAMOUFLAGE, RANGER_BINDING_SHOT |
| `mystic` | MYSTIC_VOID_STEP, MYSTIC_STARFALL, MYSTIC_CELESTIAL_BOND, COSMIC_RIFT, GRAVITON_FIELD |
| `paladin-guardian` | PALADIN_AVENGING_WRATH, PALADIN_HOLY_GROUND, PALADIN_SACRIFICIAL_SHIELD |
| `sorcerer-elementalist` | SORCERER_ARCANE_MISSILES, SORCERER_ELEMENTAL_SHIELD, SORCERER_TIME_WARP |
| `technomancer` | OVERCHARGE, NANITE_SWARM (DEPLOY_DRONE, OVERLOAD_BEAM, REPAIR_NANITES already existed) |
| `envoy` | (already had all unlock nodes – no changes needed) |
| `cleric-divinity` | CLERIC_HOLY_RESURGENCE, CLERIC_BLESSED_GROUND, CLERIC_MARTYRS_RESOLVE (now root nodes) |

### 2. Class Config Additions

Standalone MythicLib skills added to class `skills:` sections (with `unlocked-by-default: false`) so players can bind them to skill slots after unlocking via the skill tree:

| Class | Skills Added |
|-------|-------------|
| Soldier (`soldier.yml`) | COMBAT_STANCE, SUPPRESSING_FIRE, TACTICAL_RELOAD |
| Operative (`operative.yml`) | TRICK_ATTACK, EVASION_PROTOCOL |
| Mystic (`mystic.yml`) | COSMIC_RIFT, GRAVITON_FIELD |
| Technomancer (`technomancer.yml`) | OVERCHARGE, NANITE_SWARM |

> Classes that already had their custom skills registered (Cleric, Ranger, Paladin, Sorcerer, Envoy) were not changed.

### 3. Profile GUI – `/p` Menu (`MMOCore/gui/player-stats.yml`)

Two new buttons added to the player profile menu at slots **40** and **41** (Row 5, previously empty):

- **Slot 40 – Open Skills** (`function: skills`): Opens the skill list GUI where players can view and upgrade learned skills.
- **Slot 41 – Open Skill Tree** (`function: skill-tree`): Opens the class skill tree GUI where players can spend skill-tree points to unlock new abilities.

### 4. Skill Mapping Reference (`config/skills/mapping.yml`)

Created a reference/documentation file mapping every custom skill to:
- Its MythicLib skill ID
- Display name and icon material
- Which class(es) use it
- Skill tree node ID, coordinates, and prerequisites

> This file is **not loaded by any plugin** – it is a reference for server admins.

---

## Where Things Live

| What | Where |
|------|-------|
| MythicLib skill definitions | `MythicLib/skill/*.yml` |
| MMOCore class configs | `MMOCore/classes/*.yml` |
| MMOCore skill trees | `MMOCore/skill-trees/*.yml` |
| Profile GUI config | `MMOCore/gui/player-stats.yml` |
| Skill menu GUI config | `MMOCore/gui/skill-list.yml` |
| Skill tree GUI config | `MMOCore/gui/skill-tree.yml` |
| Skill mapping reference | `config/skills/mapping.yml` |

---

## How to Verify (Server Admin Checklist)

1. **Reload/restart** the server after deploying these config changes.
2. Log in and run `/p` (or `/profile`) – confirm the "Open Skills" and "Open Skill Tree" buttons appear in slots 40 and 41.
3. Click "Open Skills" – confirms the skill list opens.
4. Click "Open Skill Tree" – confirms the skill tree GUI opens.
5. As a Soldier: confirm you have skill-tree points and can see the Shield Bash / Warriors Leap / Battle Cry / Combat Stance / Suppressing Fire / Tactical Reload unlock nodes in your skill tree.
6. Spend a skill-tree point on a skill node – confirm the skill is added to your profile and you can bind it to a skill slot.
7. Bind the skill and use it – confirm cooldown and mana cost apply correctly.
8. Repeat for Operative, Ranger, Mystic, Paladin, Sorcerer, Technomancer, Cleric.
9. Confirm all previously existing skills still function normally.
10. Check the console for any YAML load errors or skill registration warnings.

---

## Assumptions Made

1. **Skill unlock trigger syntax**: Used `unlock_skill{skill=SKILL_ID}` consistent with the existing Technomancer and Envoy skill trees. The alternative `skill{skill="ID";level=1}` seen in the broken Cleric tree was replaced with `unlock_skill` for consistency.
2. **Skill node positions**: Placed all skill unlock nodes as `root: true` at coordinates outside the main stat tree grid (e.g., x: -4, x: 7, y: 3, y: 4). This avoids any overlap with existing stat nodes and keeps them accessible without requiring stat node prerequisites.
3. **Cleric-divinity tree**: The missing stat nodes were fully recreated based on the Cleric class theme (healing, mana, health, armor). The max-point-spent value (30) was kept as-is.
4. **GUI slots**: Slots 40 and 41 were confirmed empty (not used by any existing GUI items).
5. **`skill-tree` function name**: Based on the existing `skill_shop_button` in `skill-list.yml` which uses `command{format="skilltree"}`, the function name `skill-tree` was used in the profile menu. If this function name differs in your MMOCore version, it may need to be adjusted to `command{format="skilltree"}` instead.
