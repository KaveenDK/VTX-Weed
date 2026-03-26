# 🌿 vtx_weed - Advanced Zero-Lag Weed Processing

A highly optimized, modern, and secure weed harvesting and processing script built specifically for the **Qbox** framework. It features zero-lag prop rendering, a dynamic visual growth system, a realistic multi-step processing progression (Harvest ➔ Crush ➔ Package), a beautiful glass-morphism UI, strict server-side security, and advanced Discord logging.

**Author:** KaveeNDK  
**Framework:** Qbox (`qbx_core`)

---

## ✨ Features

- **Zero-Lag Prop Spawning:** Utilizes `ox_lib` points. Props are only spawned locally when a player is within the radius and deleted when they leave, saving massive amounts of client memory.
- **Dynamic Visual Growth:** Plants feature 3 visual growth stages over time. Players can actually watch the plants grow from seedlings to harvestable size. Harvesting is blocked until Stage 3.
- **Multi-Step RP Progression:** - 1️⃣ Harvest fully grown plants to get `Weed Leaves`.
  - 2️⃣ Use the **Crushing Table** to grind the leaves down into `Crushed Weed`.
  - 3️⃣ Take the Crushed Weed and `Empty Baggies` to the **Processing Bench** to package them into the final product.
- **Smart Processing Bench UI:** - Custom glass-morphism UI matching the server theme (`#1497e4`).
  - Only one player can view the menu at a time (State-locked).
  - Real-time NUI progress bar and timer.
  - Configurable hourly processing limits (e.g., max 3 processes per hour).
- **Native Notifications:** Seamlessly bridged to your server's default UI pack via `lib.notify`.
- **Highly Secure & Exploit-Proof:** 100% Server-side source of truth. Prevents duplication glitches, state spoofing, and unauthorized access.
- **Advanced Discord Logs:** Detailed webhook logging for harvesting, crushing, starting a process, collecting items, and exploit attempts (Includes Character Name, Discord Mention, Steam ID, and Server ID).

---

## 📦 Dependencies

Ensure you have the following resources installed and updated:

- [`qbx_core`](https://github.com/Qbox-project/qbx_core)
- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`ox_target`](https://github.com/overextended/ox_target)
- [`ox_inventory`](https://github.com/overextended/ox_inventory)

---

## 🛠️ Installation Guide

**Step 1: Download & Place Resource**
Extract the `vtx_weed` folder into your server's `resources` directory (e.g., `resources/[scripts]/vtx_weed`).

**Step 2: Add Items to ox_inventory**
Open `ox_inventory/data/items.lua` and add the item snippets found in `vtx_weed/installation/items.lua`:

```lua
['weed_leaf'] = {
    label = 'Weed Leaf',
    weight = 10,
    stack = true,
    close = true,
    description = 'Freshly harvested weed leaves, ready to be crushed.',
    client = { image = 'weed_leaf.png' }
},
['crushed_weed'] = {
    label = 'Crushed Weed',
    weight = 10,
    stack = true,
    close = true,
    description = 'Finely crushed weed, ready to be packaged.',
    client = { image = 'crushed_weed.png' }
},
['weed_baggy_empty'] = {
    label = 'Empty Weed Baggy',
    weight = 1,
    stack = true,
    close = true,
    description = 'Small empty baggies used for packaging goods.',
    client = { image = 'weed_baggy_empty.png' }
},
['weed_package'] = {
    label = 'Weed Package',
    weight = 200,
    stack = true,
    close = true,
    description = 'A fully processed and packed bag of weed.',
    client = { image = 'weed_package.png' }
},
```

**Step 3: Setup Images**
You must place your item images (`weed_leaf.png`, `crushed_weed.png`, `weed_baggy_empty.png`, and `weed_package.png`) into **BOTH** of the following directories:

1. `vtx_weed/html/images/` (For the Bench UI)
2. `ox_inventory/web/images/` (For the Player Inventory)

**Step 4: Configuration**
Open `shared/config.lua` and configure your settings:

- Set your **Discord Webhook URLs** (Harvest, Crush, Process, Exploit).
- Adjust plant coordinates, crushing table, and packaging bench locations.
- Change processing times, stage growth timers, item amounts, and hourly limits if needed.
- Update `Config.ThemeColor` to match your server's brand.

**Step 5: Start the Script**
Add the following line to your `server.cfg`:

```cfg
ensure vtx_weed
```

---

## ⚙️ Configuration File Overview (`shared/config.lua`)

| Setting             | Description                                                                               |
| ------------------- | ----------------------------------------------------------------------------------------- |
| `Config.ThemeColor` | The hex color used for the NUI and Discord embeds.                                        |
| `Config.Webhooks`   | Add your Discord channel webhooks here for detailed logging (Separated by action types).  |
| `Config.Plants`     | Configure the 3 visual growth stages, growth timers, random item amounts, and locations.  |
| `Config.Crushing`   | Configure the intermediate crushing table recipe, progress bar time, and coordinates.     |
| `Config.Bench`      | Configure the final packaging recipe (inputs/output), processing time, and hourly limits. |

---

## 🛡️ Exploit Protection

This script features strict `lib.callback` validation. If a player attempts to trigger the `startProcessing`, `crushWeed`, or `collectOutput` events without having the required items or without the bench being properly locked to their Server ID, it will immediately deny the request and send an "Exploit Detected" log to your Discord webhook.

---

**Developed with ❤️ by KaveeNDK**
