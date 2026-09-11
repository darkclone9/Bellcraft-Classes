# CoreTools + /menu + Auction House + Town Economy

Bellcraft player hub and town government. **CoreTools 1.4.3+ must be installed** (MenuCreator, AuctionHouse, Economy). PacketEvents is required by CoreTools.

## What was broken

`/menu` Auction House did nothing for normal players because:

1. This repo never committed a `/menu` YAML (live MenuCreator/AuctionHouse dirs were empty or VPS-only).
2. CoreTools jar `configs/commands.yml` defaults **`permission: 'OP'`** on both `menu-creator` and `auctionhouse`. Non-ops clicking `ah` / `core-auctionhouse` fail silently.

## Player-facing `/menu`

Two layers (same buttons). Use both; they do not fight if you follow deploy below.

| Surface | File | Open command |
|---------|------|----------------|
| GUIPlus hub (primary) | `GUIPlus/CustomGuis/menu.yml` | `/menu` (Skript intercept + GUIPlus alias) |
| CoreTools MenuCreator | `MenuCreator/menu.yml` | `/core-menu menu` |

Skript `Skript/scripts/server-menu.sk` **cancels** `/menu` and runs `gui open menu <player>` so an OP-gated CoreTools alias cannot swallow the click.

Auction House button runs:

```
core-auctionhouse vanilla_example <player>
```

as OP/console so the AH GUI opens even before you merge the permission fix. Bank button opens GUIPlus `bank`.

`vanilla_example` is the AuctionHouse id CoreTools extracts from the jar on first start. If your live file uses another id, change it in:

- `GUIPlus/CustomGuis/menu.yml` (command on the gold block)
- `CoreTools/scripts/bellcraft-menu.yml` (`open_auctionhouse`)

## Deploy

Copy into `plugins/` (paths relative to this repo):

```
GUIPlus/CustomGuis/menu.yml
GUIPlus/CustomGuis/bank.yml
GUIPlus/CustomGuis/ranks.yml
MenuCreator/menu.yml
CoreTools/scripts/bellcraft-menu.yml
Skript/scripts/server-menu.sk
Skript/scripts/town-economy.sk
Skript/scripts/town-election.sk
Skript/scripts/mayor-election.sk
LuckPerms/groups/town_mayor.yml
LuckPerms/groups/town_banker.yml
LuckPerms/groups/town_sheriff.yml
```

**Merge, do not replace** `plugins/CoreTools/configs/commands.yml` with `CoreTools/configs/commands.yml`. Set `permission: ''` on `menu-creator` and `auctionhouse` (and keep every other feature key from the jar default).

Merge banker/sheriff ranks from `Towny/settings/townyperms-ranks.snippet.yml` into `plugins/Towny/settings/townyperms.yml`.

Reload:

```
/gui reload
/skript reload server-menu
/skript reload town-economy
/skript reload town-election
/skript reload mayor-election
/coretools reload
/lp importgroups          (or restart if YAML storage)
/ta reload
```

If AuctionHouse folder is empty, start the server once with CoreTools installed so it extracts `vanilla_example.yml`, **or** copy the example from the jar (`AuctionHouse/vanilla_example.yml`).

## Permissions to grant `default`

| Node | Why |
|------|-----|
| (none for `/menu` / `/ah` after commands.yml merge) | Empty CoreTools permission = everyone |
| `townelection.admin` | Staff who start/cancel elections without being mayor |
| `mayorelection.admin` | Compat wrapper `/mayorelection` |
| `towneconomy.admin` | Force `/towntax collect` |

LuckPerms groups `town_mayor`, `town_banker`, `town_sheriff` are granted automatically when a candidate wins.

Optional: disable Towny's own `price_upkeep` if you do not want double upkeep (Skript already withdraws size-based upkeep from the town bank).

## Commands

| Command | Who | Effect |
|---------|-----|--------|
| `/menu` | players | Hub (Auction House + Bank) |
| `/bank` | players | Wallet, personal vault, town bank, projects |
| `/ah` / `/core-auctionhouse vanilla_example` | players (after perm merge) | Auction House |
| `/townproject` | residents | Project GUI; click then type an amount |
| `/townproject create <name> <goal>` | mayor/banker/admin | New project |
| `/townproject deposit <name> <amount>` | residents | Fund a project (`/t deposit`) |
| `/towntax info` | residents | Size-based tax + upkeep preview |
| `/towntax collect` | admin | Run a cycle now |
| `/townelection start mayor\|banker\|sheriff <c1> [c2...]` | mayor/admin | Per-town vote |
| `/townelection cancel` / `status` / `holders` | mayor/admin | Manage / inspect |

## In-game test plan

1. Non-op player: `/menu` opens the hub (not a silent close).
2. Click **Auction House** — CoreTools AH GUI opens (`vanilla_example`).
3. `/menu` → **Bank** — wallet + town bank lore; deposit/withdraw personal money; **Deposit to Town Bank** runs `/t deposit`; **Town Projects** opens the Skript GUI.
4. Two players in the same town: `/townelection start banker Steve Alex` — only those residents' `yes`/`no`/`npc` chat votes count. Winner gets `town_banker`.
5. `/townelection start mayor Steve` — winner gets `town_mayor` and `/ta mayor <town> Steve`.
6. `/townproject create walls 5000` as mayor; other resident clicks it, types `100`, town bank rises and project funded increases.
7. `/towntax collect` as admin — online residents are charged size-based tax (`/t deposit`); upkeep is withdrawn from the town bank once per town.
8. A player in a different town cannot vote in the first town's election.
