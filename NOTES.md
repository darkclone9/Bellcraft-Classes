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

### 3. Profile GUI – `/p` Menu (GUIPlus replacement)

The MMOCore built-in profile GUI (`MMOCore/gui/player-stats.yml`) had persistent button bugs where click handlers silently failed. To work around these MMOCore GUI issues, the `/p` menu has been **replaced with a GUIPlus custom GUI**.

#### What Changed

- **New file**: `GUIPlus/CustomGuis/profile.yml` — A GUIPlus-powered profile menu that opens via `/p`.
- **Modified**: `MMOCore/commands.yml` — Removed `p` and `profile` aliases from the MMOCore `player` command so that `/p` is handled by GUIPlus instead.
- The original `MMOCore/gui/player-stats.yml` is kept as-is (still accessible via `/player` if needed).

#### GUIPlus Profile Layout (6 rows, 54 slots)

| Row | Slots | Contents |
|-----|-------|----------|
| 1 | 0–8 | Black glass border |
| 2 | 10–12 | Mining, Woodcutting, Farming professions |
| 2 | 15–16 | Player profile head, Party button |
| 3 | 19–21 | Fishing, Alchemy, Smithing professions |
| 4 | 28–29 | Enchanting, Smelting professions |
| 4 | 32–34 | Physical / Dexterity / Intellect stat displays |
| 5 | 38–42 | **Clickable buttons**: Attributes, Quests, Abilities, Skill Tree, Change Class |
| 6 | 49 | Close button |

#### Clickable Buttons (Row 5)

| Slot | Label | Command Executed |
|------|-------|-----------------|
| 38 | Attributes | `mmocore attributes` |
| 39 | Quests | `mmocore quests` |
| 40 | Abilities | `mmocore skills` |
| 41 | Skill Tree | `mmocore skilltrees` |
| 42 | Change Class | `mmocore class` |
| 16 | Party | `mmocore party` |
| 49 | Close | Closes the menu |

All buttons use GUIPlus `close-inventory` + `command` click events, bypassing MMOCore's GUI handler entirely.

> **Why GUIPlus?** MMOCore's built-in profile GUI handler has bugs where registered `function:` click handlers (e.g., `skills`, `skill-tree`) silently fail on certain server configurations. GUIPlus handles click events independently via its own event system, avoiding these issues entirely.

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
| Profile GUI config (GUIPlus) | `GUIPlus/CustomGuis/profile.yml` |
| Profile GUI config (old MMOCore) | `MMOCore/gui/player-stats.yml` |
| Skill menu GUI config | `MMOCore/gui/skill-list.yml` |
| Skill tree GUI config | `MMOCore/gui/skill-tree.yml` |
| Skill mapping reference | `config/skills/mapping.yml` |

---

## Deployment Instructions

After pulling these config changes from the repository, apply them to the live server:

1. **Copy updated files** to your server's plugin data folders:
   - `GUIPlus/CustomGuis/profile.yml` → `plugins/GUIPlus/CustomGuis/profile.yml`
   - `MMOCore/commands.yml` → `plugins/MMOCore/commands.yml`
   - `MMOCore/gui/skill-list.yml` → `plugins/MMOCore/gui/skill-list.yml`
   - Any new class files in `MMOCore/classes/` → `plugins/MMOCore/classes/`
   - Any new skill tree files in `MMOCore/skill-trees/` → `plugins/MMOCore/skill-trees/`
   - Any new MythicLib skill files in `MythicLib/skill/` → `plugins/MythicLib/skill/`

2. **Restart the server** (or run `/gui reload` for GUIPlus and `/mmocore reload` for MMOCore).

3. **Verify** using the checklist below.

---

## How to Verify (Server Admin Checklist)

1. **Reload/restart** the server after deploying these config changes.
2. Log in and run `/p` – confirm the GUIPlus profile menu opens (titled "Your Character", 6 rows, black glass border).
3. Click **Abilities** (Nether Star, slot 40) – confirm the MMOCore skill list opens.
4. Reopen with `/p`, click **Skill Tree** (Experience Bottle, slot 41) – confirm the skill tree GUI opens.
5. Reopen with `/p`, click **Attributes** (Golden Apple, slot 38) – confirm the attributes GUI opens.
6. Reopen with `/p`, click **Quests** (Book, slot 39) – confirm the quest list opens.
7. Reopen with `/p`, click **Change Class** (Armor Stand, slot 42) – confirm the class select GUI opens.
8. Reopen with `/p`, click **Party** (Cake, slot 16) – confirm the party menu opens.
9. Reopen with `/p`, click **Close** (Arrow, slot 49) – confirm the menu closes.
10. Verify profession levels and player stats display correctly in the item lore (requires PlaceholderAPI + MMOCore expansion).
11. As a Soldier: confirm you have skill-tree points and can see the Shield Bash / Warriors Leap / Battle Cry / Combat Stance / Suppressing Fire / Tactical Reload unlock nodes in your skill tree.
12. Spend a skill-tree point on a skill node – confirm the skill is added to your profile and you can bind it to a skill slot.
13. Bind the skill and use it – confirm cooldown and mana cost apply correctly.
14. Repeat for Operative, Ranger, Mystic, Paladin, Sorcerer, Technomancer, Cleric.
15. Confirm all previously existing skills still function normally.
16. Check the console for any YAML load errors or skill registration warnings.

---

## Troubleshooting: GUIPlus Profile Menu

If after restarting the server the `/p` menu buttons still do nothing or the GUI does not open:

1. **Confirm GUIPlus is installed and enabled**: GUIPlus must be installed and running on the server. Check startup logs for `[GUIPlus]` messages.

2. **Confirm the profile GUI file is in place**: Check that `plugins/GUIPlus/CustomGuis/profile.yml` exists and contains `commandAlias: p`.

3. **Reload GUIPlus**: Run `/gui reload` to reload all GUIPlus custom GUIs.

4. **Check for command conflicts**: If `/p` still opens the old MMOCore profile menu, confirm that `plugins/MMOCore/commands.yml` has `aliases: []` for the `player` command (not `aliases: [p, profile]`). Restart the server after changing MMOCore commands.

5. **Check permissions**: Ensure players have the `mmocore.skills`, `mmocore.skilltrees`, `mmocore.attributes`, `mmocore.quests`, and `mmocore.class-select` permissions. Without these, the underlying MMOCore commands dispatched by the buttons will be silently blocked.

6. **Check PlaceholderAPI**: The profession levels, stats, and player info in the item lore require PlaceholderAPI with the MMOCore expansion installed. Run `/papi ecloud download MMOCore` and `/papi reload` if placeholders show as raw text (e.g., `%mmocore_level%` instead of a number).

7. **Check the console for errors**: Look for `[GUIPlus]` error lines after `/gui reload`, particularly around loading `profile.yml`.

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

### 5. Ranks GUI & Town Mayor LuckPerms Group

#### What Changed

- **New file**: `LuckPerms/groups/town_mayor.yml` — LuckPerms group definition for the Town Mayor rank. Grants all relevant Towny mayor permissions and the `&6[Mayor]` chat prefix at weight 100.
- **New file**: `GUIPlus/CustomGuis/ranks.yml` — A GUIPlus ranks info menu accessible via `/ranks`. Displays all server ranks (Default and Town Mayor) with descriptions and perk lists.
- **Modified**: `GUIPlus/CustomGuis/profile.yml` — Added a **Ranks** button (GOLDEN_HELMET, slot 43, Row 5) that opens the ranks GUI via `gui open ranks %player%`.

#### LuckPerms: Town Mayor Group

| Field | Value |
|-------|-------|
| Group name | `town_mayor` |
| File | `LuckPerms/groups/town_mayor.yml` |
| Prefix | `&6[&lMayor&6]&r` at weight 100 |
| Permissions | All `towny.command.town.*` mayor commands, `towny.town.mayor`, `towny.town.spawn.others` |

To assign a player the Mayor rank in-game:
```
/lp user <player> parent add town_mayor
```
To remove:
```
/lp user <player> parent remove town_mayor
```

#### Ranks GUI Layout (3 rows, 27 slots)

| Slot | Item | Contents |
|------|------|----------|
| 0–8 | Gold Block | Top border |
| 10 | Stone Sword | Default rank info |
| 12 | Golden Helmet | Town Mayor rank info |
| 22 | Arrow | Close button |
| Other | Gold Block | Border filler |

#### Deployment

1. Copy `LuckPerms/groups/town_mayor.yml` → `plugins/LuckPerms/groups/town_mayor.yml` and run `/lp importdata` or restart.
2. Copy `GUIPlus/CustomGuis/ranks.yml` → `plugins/GUIPlus/CustomGuis/ranks.yml`.
3. Run `/gui reload` to load the new ranks GUI.
4. The `/ranks` command and the **Ranks** button in `/p` (slot 43) will now open the ranks info menu.

---

## Assumptions Made

1. **Skill unlock trigger syntax**: Used `unlock_skill{skill=SKILL_ID}` consistent with the existing Technomancer and Envoy skill trees. The alternative `skill{skill="ID";level=1}` seen in the broken Cleric tree was replaced with `unlock_skill` for consistency.
2. **Skill node positions**: Placed all skill unlock nodes as `root: true` at coordinates outside the main stat tree grid (e.g., x: -4, x: 7, y: 3, y: 4). This avoids any overlap with existing stat nodes and keeps them accessible without requiring stat node prerequisites.
3. **Cleric-divinity tree**: The missing stat nodes were fully recreated based on the Cleric class theme (healing, mana, health, armor). The max-point-spent value (30) was kept as-is.
4. **GUI slots**: Slots 40 and 41 were confirmed empty (not used by any existing GUI items).
5. **`skill-tree` function name**: The correct MMOCore built-in function names are `skills` (opens skill list menu) and `skill-tree` (opens skill tree menu). These are the function IDs registered in MMOCore's ProfileGUI handler. The `command{format="..."}` syntax used previously is not valid for this GUI type and was the root cause of the buttons doing nothing when clicked. The `skill_shop_button` in `skill-list.yml` was also corrected to use `item`/`slots` field names and `function: skill-tree`.
