# AuctionHouse

CoreTools extracts `vanilla_example.yml` into `plugins/AuctionHouse/` on first start.
Bellcraft `/menu` opens that id:

```
/core-auctionhouse vanilla_example <player>
```

If this folder is empty on the VPS, either:

1. Restart with CoreTools 1.4.3 installed so the jar default is written, or
2. Copy `vanilla_example.yml` out of `CoreTools-1.4.3.jar` (path inside the jar is typically `AuctionHouse/vanilla_example.yml`).

The shop YAML should keep `permission: ''` so players are not blocked after the command permission is fixed.

Do not commit a 1500-line dump of the jar example here; the live file is generated and may already exist on the VPS.
