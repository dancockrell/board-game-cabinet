# Atalanta full-sheet batch 01

Four built-in image-generation calls produced four untouched 1774 × 887 candidate sheets. Each has eight columns and four action rows: walk, bow attack, hurt, defeat. SOUTH, NORTH, EAST and WEST supply **128 observed figure cells against 128 requested**. This does not establish 128 distinct useful frames. **Zero frames are runtime-admitted by this batch.**

Files live in `art_batches/atalanta_batch_01/`. Exact prompts, generator source paths, SHA-256 hashes and requested/observed counts are recorded in `manifest.json`. No individual-pose call, external generator, paid API, raster repaint, white-background removal or mirrored direction was used. Original magenta-backed PNGs are unchanged.

## What the sheets add

The broad adult identity, ivory/green tunic, braid, sandals and bow presentation are recognizable across the four sheets. Hurt and collapse rows supply much broader body-position coverage than the current standing/walking library. These are useful candidates for selecting coherent action sequences; they are not replacements for the existing accepted clips.

## Admission findings

- SOUTH and NORTH archery rows aim sideways despite their front/rear bodies. These cannot replace directional attacks unchanged.
- EAST walking mostly repeats one stride phase. Eight visible cells are not eight meaningful gait phases.
- WEST hurt introduces a loose arrow during recoil. Its continuity needs a sheet repair or careful row selection.
- Some cells have subtle near-duplicate gestures and size/registration changes.
- The generated grid is approximately regular, not mechanically perfect. The native review uses manually identified row boundaries and metadata-only dominant-component regions to prevent neighboring arrows/body fragments entering a cell.
- Dominant-component analysis can omit detached props; `regions.json` records omitted foreground pixel counts and marks every crop provisional. It never modifies the source raster and does not prove correct anatomy or motion.
- Final admission still requires row-specific pivots, coherent sequencing and review alongside the existing character at battle scale.

## Native review

Run `Godot --path . --script art_batches/atalanta_batch_01/review.gd`. It plays all sixteen rows in a labelled 4 × 4 comparison for 240 display frames. This is an editor/source-only candidate study; raw file loading is intentional and is not an exported-game implementation.

Native Godot 4.3 Compatibility playback completed successfully on 2026-09-08. Captures are in `outputs/Atalanta-Batch-01-Native-Regions/` outside the repository. The viewed capture confirmed chroma removal and that provisional regions remove the obvious neighboring-cell fragments. No gameplay or full-match claim follows from this study.

`analyze_regions.py` reads PNGs through Pillow/NumPy/SciPy and writes rectangle metadata only. Native preview chroma-keying is a shader operation. Re-running analysis must leave all manifest PNG hashes unchanged.

## Local shared archive

The complete batch is copied to `C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-atalanta-full-sheet-batch-01-2026-09-08/`. Archive PNG hashes were compared with the manifest. This is a local shared candidate copy, not a public repository publication or art admission.
