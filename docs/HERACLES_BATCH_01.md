# Heracles full-sheet batch 01

2026-09-08. Four complete directional sheets requested and produced using built-in image generation, plus one whole-sheet west repair. Each current sheet has 8 columns and 4 action rows: walk, run, club strike, defeat. **128 visible current candidate cells; zero runtime-admitted frames.** The repair is another attempt at 32 of those cells, not additional animation coverage. Unique usable frames have not been established.

Sources and exact prompts are in `art_batches/heracles_batch_01`. PNGs are unchanged generator output, 1774 by 887, solid magenta backing. `manifest.json` records original source paths, SHA256 hashes, row order, counts and limitations. `record.py` recomputes metadata only; it does not edit images. `west-first.png` preserves the unsuccessful first west attempt; `west.png` is the partially improved whole-sheet repair.

The same bronze skin, lion pelt, red skirt and pixel treatment are retained across four directions. The defeat rows give new recoil-to-ground arcs and the attack rows provide broad club anticipation/follow-through candidates. They remain source material for admission, not a claim of final motion quality.

## Native inspection

Run `Godot --path . --script art_batches/heracles_batch_01/review.gd -- --capture=<absolute-output-directory>`. This isolated development preview reads original images directly and displays all sixteen action rows simultaneously over a dark background with shader chroma keying. It intentionally demonstrates naive equal-cell slicing; it is not a packaged game feature. Native Godot 4.3 playback completed two cycles and captures were inspected. Study: workspace `outputs/Heracles-Batch-01.mp4`.

Observed issues that prevent admission:

- Some club and fallen-body silhouettes cross equal-column crop boundaries, producing clipped parts or neighboring fragments. These require individually measured regions and pivots, or a wider-cell regeneration.
- West repair improves many walk hands but walk column 7 loses its club; run poses still change weapon ownership. Original west has more obvious swaps and occasional double-club readings.
- North walk column 6 lacks a visible club.
- Gaits contain repeated-looking contacts rather than eight reliably distinct evenly spaced phases; do not count visible cells as unique usable animation.
- Defeat staging and attack arcs need aligned native review, including weapon ownership and equipment continuity before integration.

For the next broad-weapon batch, use four columns by eight rows, with each eight-frame action spanning two rows. This keeps thirty-two requested cells while giving each club swing and falling body a wider footprint.

The whole batch is copied to local shared candidates at `shared-game-environment-library/assets/candidates_needing_review/olympus-heracles-batch-01-2026-09-08`. It is not published to that public library. Current runtime Resources and game code are untouched; Windows exports exclude `art_batches/*`.
