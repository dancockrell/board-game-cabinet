Current status: EAST has four authored walking key poses connected to the board. WEST has seven native-reviewed walking poses connected to the board; four-key history below is superseded by the inbetween admission at the end. The failed experiments below are historical; the natural-palette foundation and coordinator admission at the end describe the current implementation.

# Heracles lateral walk: rejected experiment

2026-09-08. Status: historical failed attempts below; **a new four-phase EAST walk Resource is now available for coordinator integration**. West locomotion remains unfinished. This report is evidence of an unsuccessful bounded production attempt, not animation acceptance.

## Contract and method

Use built-in image generation only, with `assets/olympus_arena/sprites/heracles-v1.png` as the identity reference. Preserve the lion-head hood, beard, red skirt with gold hem, bronze skin, sandals, and right-hand wooden club. Target: 1536 x 1024 sheet, four columns and two rows; east-facing walk above west-facing walk. Ordered contact / passing / opposite contact / opposite passing, fixed elevated camera, stable grounded scale. Requested true transparency initially; one targeted correction requested the existing controlled magenta backing. No external API, paid model tool, or manual masking was used.

## Observed results

- First sheet: generator supplied a brown gradient instead of alpha. Several contact poses repeat the same leading leg. Rejected rather than attempting to remove a background matching skin, pelt and club.
- Targeted correction: magenta backing succeeds, but the gait becomes less sequential. East poses 1–3 retain the same contact silhouette; all four west poses retain essentially the same contact stance. The sequence would shuffle instead of walk.
- Both full sheets were inspected visually. No Resources were admitted, no roster mapping changed, and no in-engine motion acceptance is claimed.
- Stop condition reached: one generation and one targeted fix. Do not reclassify these sheets as usable walk cycles because they contain eight figures.

## Preserved sources

Local shared library directory:
`C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-heracles-lateral-rejected-2026-09-08/`

| File | Built-in generation ID | SHA-256 |
| --- | --- | --- |
| heracles-lateral-v1-rejected.png | exec-4cdedce8-e261-4555-84c3-207f8568b690 | C3F8B24B168EF7214A798DC9876B983A8D6EDAA9717C5BD70FE6F5CDCC86077C |
| heracles-lateral-v2-rejected.png | exec-5d3f99fc-ffbd-48bf-a174-620a523cf8c4 | 4B4DB85FAD283728B5C06EFA15D370F02EA023D0B19D5C7DB3CD593C5E3B2A0A |

These are preserved 2D candidates, outside the shipped game. Shared-library copies are local, not a claim of public publication.

## Next production method

The next attempt should commission **one direction and one explicit pair of opposite contact poses**, with clear colored anatomical leg annotations in the reference, then commission passing poses against that accepted pair. Large multi-direction sheets invite repeated anatomy while appearing superficially complete. Do not generate more until the parent production task chooses that bounded experiment.

## Follow-up: isolated contact pair also rejected

The coordinator authorized two further built-in calls on 2026-09-08. First request isolated two east-facing contact poses, explicitly placing the near knee behind the pelvis in the second pose. The output duplicated the same near-leg-forward contact. The final corrective request specified actual screen coordinates for both knees and feet, preserving the first pose and upper body. It again retained the same foreground thigh pointing forward. Neither pair is admitted, and passing poses were not commissioned against a failed contact pair.

Both unchanged originals are in the same local shared candidate folder:

- `heracles-east-contact-v1-rejected.png`: generation `exec-78ce9fca-60d0-44be-904c-f1e3193c84de`.
- `heracles-east-contact-v2-rejected.png`: generation `exec-3be20014-5a2f-4712-96ca-4c7782a9cbe4`.

This confirms that text-only leg-position instructions against this identity sheet are insufficient. **Do not repeat another text-only contact-pair request.** A future attempt needs a visibly posed anatomical guide or a different approved drawing workflow, preserving the 2D-only rule. Heracles lateral walk remains absent; no runtime Resource or central roster change was made.

## Follow-up: isolated colored guide

After the Atalanta single-pose method succeeded, four further Heracles calls tested that materially different method: one yellow-near/blue-far contact guide, a natural-palette restoration, one colored passing guide, and a lowered-knee natural correction. These were isolated figures, not another multi-figure sheet.

The colored passing guide produced distinct geometry, but a high raised knee instead of a restrained walking step. The requested low-knee correction reverted to a straight forward leg and changed the hanging hand/skirt. The contact recolor also failed to maintain an unambiguous far-leg shadow. Together these do not establish an accepted alternating loop. No runtime Resource was added, and no native acceptance is claimed.

All four unchanged originals and their hashes are in the existing local shared candidate directory under `isolated-guide-provenance.json`. Names start `heracles-isolated-`; both natural drawings remain unadmitted. The useful new evidence is that explicit colored **single-pose** guides can move the limbs, but this identity's palette-restoration/correction step does not reliably preserve the pose. Future work must validate preservation of that one passing pose before generating further frames.

## Visible colored pose-guide attempt

A built-in generated four-phase red/blue leg guide was supplied alongside the Heracles identity sheet. The finished result still repeats its contact and passing poses, so no runtime clip was admitted. Both sources and SHA256 provenance are preserved in the same shared folder as heracles-colored-pose-guide.png, heracles-pose-guided-rejected.png and pose-guided-attempt.json. The guide method alone did not solve anatomical continuity.


## Natural-palette isolated foundation: four usable key poses

A materially different isolated request kept natural colors throughout and requested a low passing knee with the heel lifted behind. Its first drawing establishes a useful passing silhouette; native side-by-side comparison with the original east rest confirmed coherent identity. Three subsequent isolated edits supplied opposite passing and contact roles. The two contacts visibly alternate bright foreground and shadow far thigh placement; they are not mirrored images.

`themes/heracles_east_walk.tres` contains four unchanged originals in chronological order: near-forward contact, near support/far lift passing, far-forward contact, far support/near lift passing. Total loop is 0.72 seconds. Small per-frame scale and foot-pivot adjustments normalize independently generated canvases. No 3D artwork, Python masking, paid API or generated filler frames were used.

Native evidence: `outputs/Heracles-Passing-Foundation.png` and `outputs/Heracles-Four-Phase-Study` (90 captures at 30 fps, all four ordered phases inspected). The dedicated preview accepts external sources so historical candidates can be assessed without adding them to the shipped game. `tests/test_heracles_east_walk.gd` verifies chronological texture selection, unique sources, loop and attack/stop recovery. Board integration and full-match validation belong to the coordinator.

This is a usable four-key-pose foundation, not final smooth animation. Arms and club remain restrained, body is slightly narrower than the original rest, and passing poses have less anatomical separation than contact poses. More inbetweens and cloth response remain necessary.

All four unchanged generation originals, exact prompts and hashes are preserved locally at `C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-heracles-east-foundation-2026-09-08/`. Runtime provenance is `assets/olympus_arena/sprites/heracles-east-walk.provenance.json`. Shared art has not been publicly published.

Coordinator admission: EAST is now mapped on the board. Native100-frame30fps board review inspected all four phases, authoritative movement, health/footprint alignment and stopped recovery; dedicated board test passes. WEST remains unmapped. This fills the previous east-facing slide with a four-pose foundation and does not claim final smoothness.

## WEST isolated natural-palette foundation

Four built-in generation calls produced four independent west-facing cels. The first validated a low passing pose with club in the far right hand (screen left), near left hand empty. Single-cel edits supplied near-forward extension, far-forward contact and opposite passing. No east image was mirrored. One intended passing request instead produced a useful forward-extension key, labelled by observed geometry in provenance.

The heracles_west_walk Resource orders near-forward extension, near support/far lift, far-forward contact, far support/near lift. Four original 1536 x 1024 canvases remain intact; per-frame foot pivots and scales normalize variations. The 0.72-second loop is a four-key-pose foundation, not final smooth animation. First forward foot approaches contact rather than being fully planted; arms and club remain restrained, body narrower than old rest, final cel slightly stronger pixel texture. More inbetweens and cloth response remain necessary.

Native tests/test_heracles_west_walk.gd passes 14 checks: chronological source selection, unique atlases, loop, attack return and stopped rest. tools/review_heracles_west_walk.gd captured 90 frames at 30 fps to outputs/Heracles-West-Four-Key-Study. Frames 0, 6, 11 and 17 were visually inspected beside west rest. Handedness, pelt and opposite leg overlap remain coherent. Board mapping and full-match admission remain coordinator work; WEST was not mapped by this slice.

Four unchanged originals, exact prompts and SHA256 hashes are preserved locally in C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-heracles-west-foundation-2026-09-08/. Runtime provenance: assets/olympus_arena/sprites/heracles-west-walk.provenance.json. No public shared upload.



## WEST grounded inbetweens: seven-source loop

A bounded four-call follow-up adds three real drawings: near heel-land/weight acceptance, far-leg weight acceptance, and near forward swing. These are new pose geometries, not repeated frames or retimed copies. The fourth generated candidate loses far-leg shadow separation and remains rejected in the shared candidate folder outside runtime. No eight-pose claim is made.

The existing four originals remain untouched. The Resource now orders seven unique source images over the same 0.72 seconds, with 0.09-second new transitions and a 0.18-second passing hold where the far forward-swing inbetween is still missing. The near-forward foot now proceeds into a flat planted sandal, while opposite weight acceptance moves the calf toward support. Restrained arm settling is present; a broader coherent club/pelt swing and more balanced half-cycle timing still need work.

Native test_heracles_west_walk passes 20 checks. The coordinator-owned test_heracles_west_board was updated under explicit delegation to validate all Resource frames dynamically; it passes actual source selection, authoritative movement and stopped recovery. Native review captured 90 frames at 30 fps in outputs/Heracles-West-Seven-Pose-Study, with all seven phases inspected at frames 0, 3, 6, 11, 14, 17 and 20. Video: outputs/Heracles-West-Seven-Poses.mp4. Slight independent-cel texture variation remains; this is improved grounding, not final polish or a newly exported build claim.

All four unchanged generation originals, exact prompts and hashes are local in shared-game-environment-library/assets/candidates_needing_review/olympus-heracles-west-inbetweens-2026-09-08. Runtime provenance: assets/olympus_arena/sprites/heracles-west-inbetweens.provenance.json. No public shared upload was made.
