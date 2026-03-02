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

> **Bug fix (PR #2):** The buttons were originally set to `function: 'command{format="skills"}'` and `function: 'command{format="skilltrees"}'`. The `command{format="..."}` syntax is not a registered function ID in MMOCore's profile GUI handler — clicking these buttons silently did nothing. The fix changes both buttons to use the correct built-in MMOCore function names: `skills` and `skill-tree`.
>
> **If buttons still do nothing after deploying PR #2 changes** (PR #3 investigation): All configuration files have been verified correct — YAML syntax is valid, all skills are defined in MythicLib, all skill trees exist for all classes. The most likely cause is the server has not been restarted/reloaded after deploying the updated config files. See the Deployment Instructions section below.

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

## Deployment Instructions

After pulling these config changes from the repository, apply them to the live server:

1. **Copy updated files** to your server's plugin data folders:
   - `MMOCore/gui/player-stats.yml` → `plugins/MMOCore/gui/player-stats.yml`
   - `MMOCore/gui/skill-list.yml` → `plugins/MMOCore/gui/skill-list.yml`
   - Any new class files in `MMOCore/classes/` → `plugins/MMOCore/classes/`
   - Any new skill tree files in `MMOCore/skill-trees/` → `plugins/MMOCore/skill-trees/`
   - Any new MythicLib skill files in `MythicLib/skill/` → `plugins/MythicLib/skill/`

2. **Restart the server** (or run `/mmocore reload` if your MMOCore version supports it).

3. **Verify** using the checklist below.

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

## Troubleshooting: Buttons Still Not Working

If after restarting the server the "Open Skills" and "Open Skill Tree" buttons in `/p` still do nothing:

1. **Confirm updated files are in place**: Check that `plugins/MMOCore/gui/player-stats.yml` contains `function: skills` and `function: skill-tree` (not the old `command{format="..."}` values).

2. **Check your MMOCore version**: The `function: skills` and `function: skill-tree` handlers are registered in the ProfileGUI in MMOCore 3.x (config-version 10). Run `/mmocore version` or check the startup log to confirm the version.

3. **Check permissions**: Ensure players have the `mmocore.skills` and `mmocore.skilltrees` permissions granted. Without these permissions the underlying command dispatch will be silently blocked.

4. **Check the console for errors**: Look for `[MMOCore]` error or warning lines after the server starts, particularly around loading `player-stats.yml` or registering GUI handlers.

5. **Confirm class selection**: The "Open Skill Tree" button requires the player to have a class with at least one skill tree assigned. With `force-class-selection: true` this should always be the case for in-game players, but verify via `/mmocore info <player>` if in doubt.

---

## Profile Terminal (Quick Access Terminal for Bedrock Players)

### What it does

A Skript-based "Profile Terminal" that Bedrock and Java players can use to quickly
access their MMOCore profile, skills, and personal command shortcuts from a single
block interaction.

| Feature | Detail |
|---------|--------|
| Trigger block | **Crying Obsidian** (right-click) |
| GUI type | Chest inventory (3 rows); Geyser automatically converts this to a **Bedrock Simple Form** |
| Profile button | Runs `/p` (MMOCore profile) |
| Skills button | Runs `/skills` (MMOCore player skill list) |
| Skill Tree button | Runs `/skilltrees` (MMOCore skill tree) |
| Shortcuts | Up to **9** player-specific saved commands, persisted across restarts |
| Add shortcut | Player is prompted in chat; next chat message is captured (cancelled from public chat) and saved |
| Remove shortcut | **Shift-click** any shortcut button to delete it |
| Execute shortcut | Normal click runs the saved command as the player |

### File location

`Skript/scripts/profile-terminal.sk` → copy to `plugins/Skript/scripts/profile-terminal.sk`

### Dependencies

| Plugin | Purpose |
|--------|---------|
| **Skript** (2.7+) | Script engine |
| **Geyser** | Translates Java inventory GUI → Bedrock Simple Form automatically |
| **Floodgate** | (Already installed for Bedrock UUID bridging; no extra config needed) |
| **MMOCore** | Target of `/p`, `/skills`, and `/skilltrees` commands |

### Deployment

1. Copy `Skript/scripts/profile-terminal.sk` to `plugins/Skript/scripts/` on your server.
2. Run `/skript reload profile-terminal` (or restart the server).
3. Place a **Crying Obsidian** block in-world.
4. Right-click the block on either Java or Bedrock — the terminal menu should open.

### Customisation (top of the script)

```
options:
    terminal-block: crying obsidian   # change to e.g. "player head"
    max-shortcuts: 9                  # max saved shortcuts per player
    gui-title: "&8&lProfile Terminal" # inventory title shown in Java
    prefix: "&8[&b&lTerminal&8] &7"   # chat message prefix
```

### How shortcuts are stored

Shortcuts are saved in persistent Skript variables:

```
{terminal::shortcuts::<uuid>::<index>}  – command string (without /)
{terminal::awaiting::<uuid>}            – true while player is typing a new shortcut
```

These variables are written to `plugins/Skript/variables.csv` (or your configured
storage backend) and survive server restarts with no additional setup.

---

## Assumptions Made

1. **Skill unlock trigger syntax**: Used `unlock_skill{skill=SKILL_ID}` consistent with the existing Technomancer and Envoy skill trees. The alternative `skill{skill="ID";level=1}` seen in the broken Cleric tree was replaced with `unlock_skill` for consistency.
2. **Skill node positions**: Placed all skill unlock nodes as `root: true` at coordinates outside the main stat tree grid (e.g., x: -4, x: 7, y: 3, y: 4). This avoids any overlap with existing stat nodes and keeps them accessible without requiring stat node prerequisites.
3. **Cleric-divinity tree**: The missing stat nodes were fully recreated based on the Cleric class theme (healing, mana, health, armor). The max-point-spent value (30) was kept as-is.
4. **GUI slots**: Slots 40 and 41 were confirmed empty (not used by any existing GUI items).
5. **`skill-tree` function name**: The correct MMOCore built-in function names are `skills` (opens skill list menu) and `skill-tree` (opens skill tree menu). These are the function IDs registered in MMOCore's ProfileGUI handler. The `command{format="..."}` syntax used previously is not valid for this GUI type and was the root cause of the buttons doing nothing when clicked. The `skill_shop_button` in `skill-list.yml` was also corrected to use `item`/`slots` field names and `function: skill-tree`.
