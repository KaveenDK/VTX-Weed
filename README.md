# 🌿 vc_weed - Advanced Zero-Lag Weed Processing

A highly optimized, modern, and secure weed harvesting and processing script built specifically for the **Qbox** framework. It features zero-lag prop rendering, a beautiful glass-morphism UI, strict server-side security to prevent exploits, and advanced Discord logging.

**Author:** KaveeNDK  
**Framework:** Qbox (`qbx_core`)

---

## ✨ Features

- **Zero-Lag Prop Spawning:** Utilizes `ox_lib` points. Props are only spawned locally when a player is within the radius and deleted when they leave.
- **Highly Secure:** 100% Server-side source of truth. Prevents duplication glitches, state spoofing, and unauthorized access.
- **Smart Processing Bench:** \* Only one player can view the menu at a time.
  - Real-time NUI progress bar and timer.
  - Configurable hourly processing limits (e.g., max 3 processes per hour).
- **Modern UI & Notifications:** Custom glass-morphism UI matching the server theme (`#1497e4`). Includes custom in-game notifications with sound effects.
- **Advanced Discord Logs:** Detailed webhook logging for harvesting, starting a process, collecting items, and exploit attempts (Includes Character Name, Discord Mention, Steam ID, and Server ID).

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
Extract the `vc_weed` folder into your server's `resources` directory (e.g., `resources/[scripts]/vc_weed`).

**Step 2: Add Items to ox_inventory**
Open `ox_inventory/data/items.lua` and add the item snippets found in `vc_weed/installation/items.lua`:

```lua
['weed_leaf'] = {
    label = 'Weed Leaf',
    weight = 10,
    stack = true,
    close = true,
    description = 'Freshly harvested weed leaves, ready for processing.',
    client = { image = 'weed_leaf.png' }
},
['weed_package'] = {
    label = 'Weed Package',
    weight = 200,
    stack = true,
    close = true,
    description = 'A fully processed and packed block of weed.',
    client = { image = 'weed_package.png' }
},
```

**Step 3: Setup Images**
You must place your generated item images (`weed_leaf.png` and `weed_package.png`) into **BOTH** of the following directories:

1. `vc_weed/html/images/` (For the Bench UI)
2. `ox_inventory/web/images/` (For the Player Inventory)

**Step 4: Configuration**
Open `shared/config.lua` and configure your settings:

- Set your **Discord Webhook URLs**.
- Adjust plant coordinates and bench locations.
- Change processing times, amounts, and hourly limits if needed.
- Update `Config.ThemeColor` to match your server's brand.

**Step 5: Start the Script**
Add the following line to your `server.cfg`:

```cfg
ensure vc_weed
```

---

## ⚙️ Configuration File Overview (`shared/config.lua`)

| Setting             | Description                                                                       |
| ------------------- | --------------------------------------------------------------------------------- |
| `Config.ThemeColor` | The hex color used for the NUI and Discord embeds.                                |
| `Config.Webhooks`   | Add your Discord channel webhooks here for detailed logging.                      |
| `Config.Plants`     | Configure the harvest time, respawn cooldown, random item amounts, and locations. |
| `Config.Bench`      | Configure the recipe (input/output), processing time, and hourly usage limits.    |

---

## 🛡️ Exploit Protection

This script features strict `lib.callback` validation. If a player attempts to trigger the `startProcessing` or `collectOutput` events without having the bench properly locked to their Server ID, it will immediately deny the request and send an "Exploit Detected" log to your Discord webhook.

---

**Developed with ❤️ by KaveeNDK**
