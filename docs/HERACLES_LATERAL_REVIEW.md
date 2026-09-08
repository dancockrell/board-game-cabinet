# Heracles lateral walk: rejected experiment

2026-09-08. Status: **rejected, not connected to runtime**. East/west locomotion remains unfinished. This report is evidence of an unsuccessful bounded production attempt, not animation acceptance.

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
