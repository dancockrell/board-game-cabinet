# Creature combat: normal-speed native review

Captured 2026-09-08 from source HEAD `ce9ec8e8014ac8ae791e4656acc91508bb515887` using the existing `tools/review_battlefield_motion.gd`. Concurrent untracked Atalanta candidate art was present but not referenced by this source. No gameplay, controller, renderer or review-tool code was changed. No user-play executable was launched or interrupted.

## Evidence and scope

Two independent seed-42 source-controller studies:

| Study | Match interval | Presentation | Legal deployments including warmup | State evidence |
|---|---|---|---|---|
| Main | 30–36 seconds | 180 frames, 30 fps | 5 | Controller snapshot equals authoritative session snapshot |
| Later | 60–66 seconds | 180 frames, 30 fps | 9 | Controller snapshot equals authoritative session snapshot |

Each captured frame advances the controller by 1/30 second. MP4 encoding uses 30 fps, so six recorded simulation seconds play in six seconds. Warmup is explicitly accelerated before recording. Sound is muted by the existing tool.

Workspace outputs:

- `outputs/Creature-Combat-Normal-Speed/frame-000.png` through `frame-179.png`, plus `study.json`.
- `outputs/Creature-Combat-Normal-Speed.mp4`.
- `outputs/Creature-Combat-Normal-Speed/Later/frame-000.png` through `frame-179.png`, plus `study.json`.
- `outputs/Creature-Combat-Normal-Speed-Later.mp4`.

Native source frames 000, 060, 120 and 179 in both captures were visually inspected. This is a sampled chronological visual review and two six-second motion artifacts, not complete-match validation or approval of every direction/action. The samples predominantly show Harpies, Medusa and human fighters; they do not establish Hydra/Minotaur death quality.

## Observed actionable defects

### 1. Harpy pair overlaps strongly enough to obscure individual bodies and health

In the main study at frame 060, two red ground rings remain separately visible beneath a mostly merged wing/body silhouette near the upper end of the right bridge. At frame 120, the same pair crosses the bridge with overlapping wings and health bars; distinguishing the two individuals requires the rings. In the later study at frame 179, newly deployed blue Harpies similarly overlap on the left bridge.

Action: preserve distinguishable formation spacing for members of the deployed group through bridge approach and combat, and avoid drawing their health bars directly over each other. Validate by repeating the same seed/sample and checking that two bodies and two ownership/health indicators remain legible. A sprite-frame count increase alone cannot resolve this overlap. Any gameplay spacing change must remain authoritative.

### 2. Fighters at shrines become substantially hidden by building art

Later frames 000 and 060 show a fighter at the lower-left shrine reduced mostly to partial limbs and overlapping health/ownership indicators. At frame 120, a Medusa figure attacking near the upper-right shrine is partly covered by the building frontage while another figure stands immediately below it. These are active combat positions, not background decoration.

Action: establish readable attack staging around the actual shrine footprint, or a consistent building-occlusion treatment while units fight there. Do not simply put every troop above every building: the inspected problem is loss of active-fighter readability at a specific contact point. Recheck the same 60–66 second study with the shrine frontage and fighter silhouettes both visible.

### 3. The board receives less than half of the captured window width

The native output is 1200 × 800. The playable island extends approximately x338–858, around 520 pixels wide; water occupies the large side margins. Individual fighters are only roughly 25–55 pixels tall despite the source drawings' greater detail. This is visible throughout both captures, independently of animation phase.

Action: increase the battlefield's useful screen allocation at this aspect ratio, with a compact HUD and camera/layout framing that retain both bases and bridges. Compare the same battle at the same 1200 × 800 resolution; assess troop and building size rather than only source-art resolution. The water animation can remain visible without consuming most horizontal space.

## What the evidence supports

Normal-speed source playback works and the controller/session state remained aligned in both captures. Water and character frames change during the sample. Combat proceeds through legal automated placements. The three findings above are visible readability defects, not evidence of rules divergence. No claim is made that these samples finish visual acceptance.

## Follow-up repair: authoritative Harpy formation spacing

The overlap's source was the rules state: Harpies spawned only 0.42 world units apart, then allied flight separation allowed compression to 0.32. Ground allies already reserved body room. Renderer-only displacement would have separated artwork from damage/target coordinates, so the focused fix changes allied flying spacing in `games/olympus_arena/session.gd`.

Harpies now spawn and softly separate at 1.05 world units. Opposing flyers retain the existing 0.32 minimum; their 0.8 attack range, damage and targeting remain unchanged. Ground separation and bridge constraints are unchanged. The actual state positions move, so deterministic match outcomes can naturally differ from the older seed-42 capture; identical combat outcomes are not an acceptance requirement.

Validation:

- `tests/test_harpy_formation.gd`: 60 checks passed, covering legal edge placement, traversal spacing, deterministic replay, open-water flight, real-coordinate enemy attack and coincident-ally recovery.
- Existing crowd/bridge test: 2,412 checks passed.
- Arena rules suite: 776 checks passed.
- Repeated normal-speed 30–36 second sample: 180 frames, five legal deployments including warmup, authoritative snapshot match. At frame 000 the attacking pair has independently visible bodies. One dies later in the changed battle; the capture does not pretend both survive as before.
- Controlled native traversal study: `tools/review_harpy_formation.gd`, six seconds/180 frames at 30 fps, minimum authoritative pair gap **1.05000019073486**, snapshot match true. Its fixed opening hand and disabled rival AI/shrine fire are explicit study fixtures. Frames 030 and 120 visibly show two bodies, two bars and two ground rings during movement.

Evidence videos: `outputs/Harpy-Spacing-After.mp4` (real-controller battle) and `outputs/Harpy-Formation-Native.mp4` (controlled traversal). Reports/stills are under `outputs/Creature-Combat-Normal-Speed/Harpy-Spacing-After` and `outputs/Harpy-Formation-Native`.

No sprite, ownership indicator or attack effect was moved independently of authoritative unit positions. Wing tips can still overlap at full extension; the repaired criterion is distinguishable individual bodies and ownership/health, not an artificial ban on all wing overlap. Shrine occlusion and battlefield screen allocation findings above remain outside this repair.

