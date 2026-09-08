# Authored shrine collapse

Eight new pixel drawings replace the former vertically compressed intact shrine: cracking, column failure, roof fracture, falling masonry, impact dust, secondary rubble and settling. A ninth entry is the original permanent rubble drawing, so the effect hands back to the board's persistent ruins without a second redraw.

The 1.35-second sequence uses an untouched built-in generated sheet, irregular cell bounds, explicit front-step pivots and uniform per-frame scales. The actor never changes its aspect ratio to simulate breakage. Original prompt, references and SHA256 are in assets/olympus_arena/buildings/owl-shrine-collapse-eight.provenance.json; unchanged source is also in local shared candidates/olympus-shrine-collapse-2026-09-08.

The board still owns destroyed state and footprint. Its permanent rubble is hidden during the temporary sequence, then revealed. Pause, duplicate snapshots, restored buildings and rematch cleanup retain their state contracts. Generic explosion rings and large smoke disks were removed from the separate combat-effect consumer because they obscured the authored masonry; a small camera impact remains. Small flat stone/dust particles supplement the drawn frames.

Validation: clean import, native board85 and combatFX337 checks passed. Dedicated collapse test170 checks covers all eight drawings plus the permanent rubble entry, aspect ratio, pause, repeated snapshots, reset and fixed authoritative location. Native110-frame60fps review inspected all stages at both tower and temple sizes. Early failed import captures are not admission evidence; the accepted review is Shrine-Authored-Collapse-Clean.

Limitations: the last settling drawings rearrange some rubble, and the permanent pile has minor detail differences. This is an incremental animation improvement, not final frame-by-frame cleanup.
