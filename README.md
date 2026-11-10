# NextTalent

A World of Warcraft addon for **WoW Classic Forever** that tells you which talent to pick next while leveling.

## What it does

Whenever you have unspent talent points:

- the next talent of the leveling build gets a pulsing gold frame in the talent window
- a chat message names the next talent once per free point, e.g. `NextTalent: Talent point available, next: Spirit Tap (rank 3)`

The highlight follows clicks right away, even before you apply the changes. Once the build is complete, or if your class has no build, the addon stays quiet.

## Builds

| Class | Build | Source |
|---|---|---|
| Mage | Frost (leveling), levels 10-60 | Icy Veins, WoW Forever Frost Mage Leveling guide (as of 2026-11-09) |
| Priest | Shadow (leveling), levels 10-60 | Icy Veins, WoW Forever Shadow Priest Leveling guide (as of 2026-11-02) |

The builds are defined in `Builds.lua` as one spell ID per talent point, in spending order. To add another class, add an entry for its class token (e.g. `WARLOCK`) there.

## Commands

| Command | Effect |
|---|---|
| `/nt` or `/nexttalent` | Shows the next talent and your unspent points in chat |

## Supported game versions

| Version | Interface |
|---|---|
| WoW Classic Forever | 16001 |

Forever's talent window is based on the modern Traits talent system, so the addon does not work in Classic Era.

Localized for English and German.

## Installation

The folder in your AddOns directory **must** be named `NextTalent`, otherwise WoW will not load the addon:

```bash
cd "C:/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns"
git clone https://github.com/byWulf/wow-next-talent.git NextTalent
```

Alternatively, download the repository as a ZIP and extract its contents to `Interface/AddOns/NextTalent/`.

Then restart WoW (or log out) and enable the addon in the AddOns list.
