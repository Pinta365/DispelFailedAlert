# DispelFailedAlert

Plays a sound when you cast a friendly dispel/cleanse but it removes nothing — so you instantly know a cast was wasted (the target had no debuff, or none your dispel could clear).

It tracks the friendly cleanses across all classes (Cleanse, Purify, Nature's Cure, Detox, Purify Spirit, Cleanse Spirit, Expunge/Naturalize, Remove Curse, and more) and only reacts to your own casts.

## Commands

| Command | Action |
|---------|--------|
| `/dfa` | Show commands |
| `/dfa on` / `/dfa off` | Enable / disable the alert |
| `/dfa sound` | List sounds; `/dfa sound <n>` selects and previews one |
| `/dfa test` | Play the current alert sound |
| `/dfa debug` | Toggle debug output |
| `/dfa reset` | Reset settings to defaults and reload |

## Options

**Settings → AddOns → Dispel Failed Alert** — toggle the alert, choose the alert sound, or reset to defaults.

## Alert sound

Only one sound is bundled for now — more will be added in a later update.
