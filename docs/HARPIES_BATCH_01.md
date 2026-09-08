# Harpies full-sheet batch 01

Four full 887 × 1774 portrait sheets provide **128 observed figure cells against 128 requested**, generated in four built-in calls. Each sheet has four columns and eight rows. Eight chronological frames occupy each consecutive pair of rows.

| Sheet | Facing | Actions (eight requested frames each) |
|---|---|---|
| south_a | South/front | Flight, dive attack, hurt, defeat |
| north_a | North/rear | Flight, dive attack, hurt, defeat |
| south_b | South/front | Hover, takeoff, landing, victory |
| north_b | North/rear | Hover, takeoff, landing, victory |

All four originals, exact prompts, source paths, hashes, requested/observed metadata, provisional regions and native preview are under `art_batches/harpies_batch_01/`. No individual-pose generation, mirroring, external API or raster editing was used.

**Candidate-only: zero runtime-admitted frames.** 128 visible figures does not mean 128 distinct useful frames or sixteen finished animations.

## Visual findings

The portrait four-across layout accommodates spread wings much better than dense eight-across layouts. The sheets preserve recognizable auburn hair, golden laurel, ivory/green clothing, brown/ecru wings and golden talons. Flight has visibly varied wing angles, attacks show talon extension, hurt has asymmetric wing bracing, and defeat progresses into a folded-feather body. Takeoff/landing add standing and crouched poses previously scarce in the library.

Several wing poses recur between action families. Body scale and vertical placement change between frames; admission needs measured pivots and consistent scale. The simple native-preview key leaves magenta feather-edge fringe. Victory reads mostly as wing/talon gestures and does not follow every requested microbeat. These are concrete production candidates, not final polished clips.

## Native review and tooling

`Godot --path . --script art_batches/harpies_batch_01/review.gd` plays all sixteen candidate actions in a labelled comparison. It completed 128 display ticks in Godot 4.3 Compatibility, showing each of the eight poses twice. Captures are saved outside the repository in `outputs/Harpies-Batch-01-Native/`; frames 0032 and 0056 were inspected.

The preview uses a simple chroma-key shader and provisional whole-sheet connected-body rectangles. `analyze_regions.py` reads originals and writes JSON metadata only, with Pillow/NumPy/SciPy. It does not paint, mask, resize or resave source PNGs. Whole-sheet regions avoid chopping wings at nominal row boundaries but can omit detached details or include nearby feathers. Review still determines usable poses.

This is a source-only study using raw image loading, not an exported-game scene. No gameplay, combat timing, runtime acceptance or full-match assertion follows from it.

## Shared copy

A local shared candidate archive is stored at `C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-harpies-full-sheet-batch-01-2026-09-08/`. The four PNG archive hashes match the manifest. No public shared-library push or runtime admission is implied.
