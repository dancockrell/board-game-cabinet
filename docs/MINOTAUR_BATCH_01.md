# Minotaur full-sheet batch 01

2026-09-08. Built-in image generation produced four full directional sheets and one whole-sheet north repair. Each current sheet has four columns and eight rows, with each eight-frame action spanning two rows. Actions are walk, charge, axe attack and defeat. **128 visible current candidate cells, zero runtime-admitted frames.** The repair is another attempt at 32 existing cells, not extra animation coverage. Unique usable drawings are unproven.

The source identity remains the existing brown bull-headed Minotaur with two ivory horns, tufted tail, blue Greek skirt with gold meander, bronze cuffs and doubleheaded bronze axe. Both north and south source references were inspected. No new weapon or costume was invented.

Unchanged generated PNGs, exact prompts, original source paths, SHA256 hashes and action row metadata live in `art_batches/minotaur_batch_01`. `north-first.png` preserves the initial axe-flipping attempt; `north.png` is the full-sheet repair. `record.py` only measures files and writes metadata, never edits raster art.

## Native review and limitations

`Godot --path . --script art_batches/minotaur_batch_01/review.gd -- --capture=<absolute-directory>` runs an isolated native candidate preview of all sixteen action sequences simultaneously. Two cycles were captured, including inspection of phases 5 and 7. Video is workspace `outputs/Minotaur-Batch-01.mp4`. This is a diagnostic equal-grid view, not runtime admission.

- North repair restores the axehead to screen-left across locomotion, visibly improving the initial side flipping.
- Equal-grid slicing still reveals fragments from neighboring rows, especially raised axe heads, plus minor tail/weapon clipping. Per-frame measured regions and pivots are required before integration.
- South defeat loses the visible axe in early middle poses before it returns.
- East and west attack rows contain a premature return to ready stance between raised axe and impact; their raw chronological order needs correction.
- Gaits include repeated-looking contacts. Thirty-two visible cells per sheet does not prove thirty-two distinct usable animation frames.
- The four-column layout was placed on a 1:2 portrait canvas, so its cells are still square. Future broad-weapon batches should use a **square canvas with four columns and eight rows**, yielding wide cells, and explicit empty gutters.

Local shared candidate copy: `shared-game-environment-library/assets/candidates_needing_review/olympus-minotaur-batch-01-2026-09-08`. No public shared-repository publication. Runtime files are untouched and `art_batches/*` remains excluded from Windows exports.
