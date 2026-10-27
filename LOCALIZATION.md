# Languages

Settings → Language supports English, French, Spanish, Italian, Swedish,
Norwegian Bokmål, Arabic, Turkish and Persian. Language names remain in their
native script so players can recover from selecting an unfamiliar language.
English is the default. Selection is saved in `user://progress.json` under
`language`; missing or unsupported codes fall back to English.

Editable source: `assets/locales/catalog.txt`; rebuild the runtime dictionary
with `scripts/build_translations.py`. Formatting placeholders are validated
for all nine languages. Brand names and author/license proper names remain
unchanged. Translations are bundled offline.

Arabic/Persian use Vazirmatn Bold (SIL Open Font License; source and license
bundled in `assets/fonts`). Other languages retain Montserrat Bold, with
Vazirmatn as a fallback for the language picker. Text shaping is RTL while
absolute board coordinates remain unchanged. Numeric fractions are isolated
LTR so counts retain their original order.

Entry laughter has its own softer mix, using the source recording from its
beginning rather than the trimmed idle take. It has a 200ms fade-in and a
lower normalized level and playback gain. Idle and loss laughter are unchanged.
