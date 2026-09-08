# Selected batch admission index

Reconciled against actual defeat Resources on 2026-09-08. This index covers five character batches only; it is not the total game animation count.

| Batch | North defeat | South defeat | Recorded admitted frames |
|---|---:|---:|---:|
| Atalanta batch 01 | 8 | 8 | 16 |
| Heracles batch 01 | 8 | 8 | 16 |
| Hydra batch 01 | 8 | 8 | 16 |
| Harpies batch 01 | 8 | 8 | 16 |
| Minotaur batch 01 | 8 | 0 | 8 |
| **These five batches** | **40** | **32** | **72** |

Each `art_batches/<character>_batch_01/manifest.json` now includes `runtime_admissions`: exact Resource path and hash, runtime texture path, matching batch source image and SHA256, ordered source rectangles, duration and direction. Existing admission count fields have been reconciled rather than leaving contradictory zero counts.

Verification matched all nine runtime texture hashes to exactly one original PNG in the corresponding batch. Every Resource contains eight in-bounds rectangles and eight durations totaling at most 0.78 seconds, and is nonlooping. This establishes the metadata relationship; native art admission evidence remains in the character-specific defeat admission documents and tests. No other action rows were admitted by this bookkeeping change. Observed whole-sheet counts and unknown distinct-useful-frame fields remain distinct from admitted counts.

Minotaur south remains candidate-only because early collapse poses lose the axe before it returns. Harpies admission selects defeat from the appropriate action-family sheets; other families remain candidates.

Matching existing local shared candidate manifests were updated only after verifying the source PNG hashes in those folders. The copies are under `shared-game-environment-library/assets/candidates_needing_review/`:

- `olympus-atalanta-full-sheet-batch-01-2026-09-08`
- `olympus-heracles-batch-01-2026-09-08`
- `olympus-hydra-batch-01-2026-09-08`
- `olympus-harpies-full-sheet-batch-01-2026-09-08`
- `olympus-minotaur-batch-01-2026-09-08`

All five shared manifest copies match the repository manifest hashes. No public shared-repository push was performed. This change edits metadata only and does not change assets, runtime Resources, gameplay or the source already archived for packaging at `587b93d`. Build inclusion must still be established from that build's own source and export evidence.
