Current admission: north/south defeat rows now play in gameplay (16 drawings) through themes/medusa_north_defeat.tres and themes/medusa_south_defeat.tres. Remaining rows retain candidate status. Original batch review below records the pre-admission findings.

# Medusa batch 01 — four directional action sheets

Generated 2026-09-08 with four built-in image generation calls, one full sheet per direction. This is a candidate library, not an accepted runtime replacement.

## Delivered scope

Four untouched 1774 × 887 PNG sheets: south, north, east and west. Each contains eight columns and four action rows: walk, gaze attack, hurt recovery and defeat. Requested 128 cells; visually observed 128 occupied cells. This does **not** mean 128 unique useful motion poses: similar contacts and returning rest positions occur. Accepted runtime frames from this batch: zero.

The existing ivory chiton, gold belt/diadem/bracers/sandals, olive skin and green snake-hair identity is retained. Saturated magenta backing is generated directly. No white-background masking, raster repainting, resampling or automatic mirroring was performed. Original image-generation metadata remains in every source PNG.

## Files and provenance

- `art_batches/medusa_batch_01/medusa-{south,north,east,west}-32.png`
- Exact input prompts: `prompt-{direction}.txt`.
- `manifest.json`: original generated paths, SHA256 values, image dimensions, requested and observed counts, action timing proposals, chronological region lists and candid per-row review notes.
- `inspect_sources.py`: read-only image inspection and reproducible manifest generation. It measures foreground columns to locate drawings; it does not alter raster data.
- `review_batch.gd`: candidate-only native Godot canvas playback of all 16 rows simultaneously. Reads original files directly, so it is an editor/source review tool and deliberately not an exported-game tool.

Local shared copy: `C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-medusa-batch-01-2026-09-08`. Shared candidates are not publicly published.

## Native review and practical findings

Captured 96 native frames with Godot 4.3 Compatibility/OpenGL. Video: `outputs/Medusa-Batch-01-Review.mp4` in the workspace above the repo. Native stills inspected at attack extension and fully settled defeat, as well as earlier uncorrected crops.

The generated layout has eight drawings per row, but wide defeat drawings drift outside equal column boundaries. Blind equal-grid extraction exposed neighbouring bodies. The manifest now records measured per-row drawing bounds with two-pixel padding; the corrected native preview no longer contains neighbouring sprite fragments. Full source images remain unchanged.

The four defeat rows offer clear knees-to-floor-to-side collapse progression, and attack rows provide hands and snake extension plus recovery. Hurt rows provide useful guard/flinch/brace drawings. SOUTH and EAST walks are weak as complete cycles because several cells keep the same leading leg; WEST has more varied contacts but still needs convincing opposite-leg motion. NORTH heels alternate but toe-off needs scrutiny. Attack recovery can jump, especially WEST column seven. Some snake outlines retain magenta fringing under the simple preview shader. None of these rows has received board-scale pivot registration, event timing or gameplay admission.

Do not replace current walk Resources with these merely to increase a count. Prioritize defeat and hurt admission; use action-only full sheets for the next gait repair batch. Keep eight chronological drawings per action while explicitly requesting alternating contacts, passing and lift.

## Reproduce

From the repo:

```powershell
python art_batches/medusa_batch_01/inspect_sources.py
& 'C:/Users/Admin/dev/tools/godot/bin/Godot_v4.3-stable_win64_console.exe' --path . --script art_batches/medusa_batch_01/review_batch.gd -- --capture=<absolute-review-directory>
```

The native review intentionally loops each eight-cell row for comparison, including defeat. That review loop is not proposed gameplay death behaviour.

