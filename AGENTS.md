# AGENTS.md

## Language

All documentation in this repository (README, AGENTS.md, code comments, commit messages) is written in **English**.

## Project

WoW addon `NextTalent` for **WoW Classic Forever**: while the player has unspent talent points, it highlights the next talent of a predefined leveling build in the talent window (pulsing gold frame) and announces it once per free point in chat.

- `NextTalent.toc`: addon manifest, interface `16001` (Classic Forever only, it relies on the Traits talent system), localized `Notes-deDE`
- `Locales.lua`: all user-facing strings. English is the base table, every other locale only overrides keys. Loaded first and exposed as `ns.L`.
- `Builds.lua`: one build per class token (`ns.builds.PRIEST`, ...). `order` lists one spell ID per talent point in spending order, `talents` maps spell IDs to English names (fallback label only), `firstLevel` is the level of the first talent point, `source` names where the build comes from.
- `NextTalent.lua`: reads the active trait config (`C_Traits`), finds the first step of `order` that is not purchased yet, draws the highlight on the matching button in `PlayerSpellsFrame.TalentsFrame` (`Blizzard_PlayerSpells`) and provides `/nt` (`/nexttalent`)

Talents are matched by the trait definition's spell ID, with the localized spell name as a fallback. If the player's class has no build, the addon does nothing.

When adding a user-facing string, add the key to the English base table and to every locale in `Locales.lua`. When adding a build, use spell IDs from the Forever client (e.g. via `/dump` of `C_Traits.GetDefinitionInfo`) and add its name key to `Locales.lua`.

## Installed copy

The addon is installed as a plain copy (not a clone) in:

- `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\NextTalent`

After changing the `.toc` or any `.lua`, copy them there. The folder name must stay `NextTalent`.

## Testing

There is no automated test setup. Changes are verified in game with `/reload` and the talent window open; Lua errors show up with `/console scriptErrors 1`. A syntax check is possible with `luajit -bl <file>.lua`.
