# Olympus Arena handoff â€” 2D only

Updated 2026-09-08. Private repository: https://github.com/dancockrell/board-game-cabinet

## Active authority

The user explicitly requested removal of 3D artwork. All active artwork must be 2D: authored pixel sprites, painted backgrounds, flat effects and interface drawings. No sculpted figures, modeled scenery, PBR materials, or model fallback may be introduced. Follow AGENTS.md and OLYMPUS_BOARD_ART.md. Older releases and archived documents are historical, not design authority.

The orthographic Node3D/Sprite3D coordinate infrastructure only places flat artwork and resolves picking. It does not contain or authorize volumetric artwork. Rules and authoritative state remain RefCounted and independent of presentation.

## Current implementation

Seven sprite character types: Hoplites, Atalanta, Medusa, Minotaur, Heracles, Hydra, Harpies. All have authored attacks; Hydra now has four idle/attack facings. Ground walking coverage remains incomplete for some lateral views. Pixel card portraits match deployed characters. Thunderbolt uses its flat illustrated symbol.

The modeled stage is replaced by an original painted pixel-art background. Painted bridge centers register to authoritative lanes x=-2.7 and x=2.7. A second flat image layer extends sea at wide aspect ratios. Image shaders animate water and leaf colors on the pause-aware clock. Boats and border props are painted/static. Buildings remain sprite clips; collapse/departure debris, projectiles and trails are flat drawings. Team indicators are flat outlines.

Old model makers, 3D scenery materials, GLB tools, chess/Ninth Gate 3D apps and graphical tests are removed. Their rules, sessions and notation foundations remain parked. There is no menu path to those retired scenes.

## Global removal status

The 2026-09-08 owner decision applies to every project and shared pack: 2D artwork only. Delete retired 3D assets rather than preserve them for a future return. Reuse the shared 2D art folder across Olympus, Cattle Trail, DR Companion and Pirate Island. Physical removal outside this checkout is pending: automatic approval review rejected deletion with only "blocked by policy". Do not describe an inventory or a catalog exclusion as completed deletion.

No GLB/GLTF/FBX/BLEND/OBJ files remain in the project work directory. Legacy copies in the shared library, other project checkouts, old build outputs and historical releases require separate removal. Current 2D sources, candidates and reference art remain valuable and are not deletion targets. The earlier archive-for-later decision is superseded.

## Source update after the current Windows checkpoint

Harpy north and south flight now each use eight authored wingbeat poses, with separate extended downstroke and bent-wing recovery drawings. Native60frame reviews per direction inspected all phases; both native movement/hover/pause/reset tests passed, board84 and integrated seven-character 2D match gate passed. See HARPY_RICH_FLIGHT.md. These source changes are newer than the packaged Windows checkpoint below.

## Current Windows checkpoint — richer sprites

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-richer-sprites-2026-09-08

Source: `9958b5705ea4e99fd97ea71f2671d9e89f80afee`. Package: `Olympus-Richer-Sprites-Windows.zip` (82,603,904 bytes).
ZIP SHA256: `4B0652D3412DA1E2F4A2973805C5FB6407853EE42D4E4BD105BD086EDCB2E82B`.
Executable SHA256: `973E272DF23C3E6ECD273D3F72B0EE69EEB28C650ED023C893A66B2E09B5C06E`.

Hoplite east attack now contains seventeen distinct source poses including spear raising/lowering; Hydra north/south each have eight-pose walking clips connected to movement. Source sheets stay intact, using per-frame pivots and optional calibrated absolute frame scales. Saved sound/scenery settings are included. See RICHER_SPRITES_2026-09-08.md for admission and remaining defects.

Full graphical verification passed: sprite67, continuity20, board84, stage13, roster79, app68, effects337, arena775 and preserved rule suites. Native north/south Hydra checks exercise all eight frames, movement positions and idle recovery. The integrated 2D gate inspected seven kinds,30 legal placements,963 effect samples and6756 planar drawings with no failures.

The exported executable completed1800 ticks,30 legal deployments,all seven types,13 collapse samples,result and rematch; passed=true,failures=[]. Its accelerated sampling observes six Hoplite attack phases and all eight Hydra south frames. It does not cover every action/direction; dedicated native clip/board tests and motion reviews supply the new-frame coverage. The package includes notices, per-source provenance, BUILD-NOTES.md, VALIDATION.md and VERIFICATION.json. The release's Hoplite video is a native30fps motion study, not full-match footage.

Remaining: richer Atalanta and Heracles walking, other short action/direction sequences, finer Hydra limb/tail transitions, broader combat readability and balance polish. The rear Hydra gait is an exaggerated stomp. No claim of final art approval or completed game quality. All checkpoints below are historical and superseded by this package.

## Historical Windows checkpoint

Olympus-2D-Only-Windows.zip, source e8c9454ce09b9b27e6043b2be4abdcdfa5c91630.
Executable SHA256: 9C3325D94D6ED710C546435A738683ADD03D6358E526D14B31C25B862B0A32FD.
ZIP SHA256: 52EAF7C08102BCAC0311223DFB084300EDD00D5C30D185F354E7DC186D0BE33F.
Subsequent test/documentation commits do not alter the executable. Package includes notices, per-source provenance, build notes and VERIFICATION.json. Extract and open Olympus.exe.

Native full-match 2D gate: seven sprite character types,30 legal deployments,963 effect samples,6,756 inspected planar drawings,0 failures. Rejects volumetric primitive meshes and noncoplanar multi-surface geometry, checks pause invariance and actual configured main scene. tools/verify.ps1 -Graphics includes this gate.

Full verification command passed, including preserved chess/oracle/session/notation suites, 775 arena rules,73 board,79 roster,56 app and337 combat-effect checks. Focused flat collapse75/departure22 and card16 checks passed. Final stage has11 checks including bridge registration at two aspect ratios and actual rendered stone color above the sea layer. A native render caught an alpha-layer ordering problem; the backdrop is now opaque, with a regression check for visible bridges.

The exported executable completed1,800 ticks with30 legal deployments,all seven characters,collapse,result and rematch; passed=true,failures=[] and exit0. Native exported battle image inspected at outputs/2D-Only-Export-Verification/battle-0300.png. Diagnostic simulation is accelerated, not real-time footage.

## Remaining production work

The overall game quality goal remains active. Add richer authored intermediate poses and missing lateral walking for Atalanta and Heracles, plus true Hydra locomotion. Their previous side-walk agents hit a usage limit; unfinished Heracles scaffolds are preserved outside active tests. Improve transitions and balance without restoring models. All new visual work uses the built-in image generator authorized by the user, not paid external APIs.

Hosted CI was previously unable to start due to account billing/spending limits. Local and exported verification are separate evidence; do not infer current CI green status.

## Idle playback repair — 2026-09-08

Standing actors now advance their authored idle clips. Idle facing changes preserve normalized phase; attack recovery applies only time after the action ends, and pause/rematch preserve or clear clocks respectively. Native sprite checks passed (45) and motion continuity checks passed (20). The standard graphical verification now includes motion continuity. This source change is newer than the Windows checkpoint above; that executable does not include this repair.

## Hydra lateral steps — 2026-09-08

Added separate east/west four-pose authored walk Resources. Movement selects them; standing uses idle playback, attacks retain authoritative event timing. Built-in generation plus one background-only correction; original chroma source preserved. Four ordered native poses inspected on the battlefield, resource timing checks and integrated 2D gate passed. North/south locomotion and smoother in-betweens remain unfinished. This is newer source than the downloadable Windows checkpoint.

Atalanta east/west four-pose walks are now connected to movement (native clip tests: 16 passed). Contact poses remain similar and lifted steps exaggerated; smoother intermediate poses remain required. Heracles lateral generation was rejected for repeated planted feet; see HERACLES_LATERAL_REVIEW.md. No claim of complete locomotion coverage.

## Latest Windows delivery — animated sprites

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-animated-sprites-2026-09-08
Build source: 09798cd996b6dc18b21633d687576724d139b73c. This supersedes the older downloadable checkpoint above and includes idle playback plus Atalanta/Hydra lateral walks.
Executable SHA256: 0F5867B98542B603960EEF1230B15F60BE4D8EBBE26284B02CDFCAD57F01582D.
ZIP SHA256: CB4373FE437D2622FFA8777BE78A093522D549126DA20A6C673A15C58D1DA76E; 76,820,127 bytes.
Native exported verification: passed=true, failures=[], exported=true, 1,800 ticks, 30 legal deployments, seven characters, 13 collapse samples, result/state agreement and rematch reset. Battle capture inspected at outputs/Animated-Sprites-Export-Verification/battle-0300.png. Accelerated diagnostic is not real-time footage. The animated_idle_samples field groups Hydra and Harpy motion samples and should not be interpreted as proof of distinct idle frames.

## Attached movement indicators

Unit team footprints, health bars, hit/ability rings and damage-number origins now follow the same horizontal smoothing offset as the sprite. Replica roots remain exactly at authoritative coordinates. Native board tests: 81 checks passed, including movement, indicator alignment and pause invariance. This source change is newer than the animated-sprites Windows release above.

The additional source capture run produced battle and collapse images, then ended without a result/report; complete-match acceptance from that run is unproven. Battle frame 300 was inspected. The previous published executable retains its separately verified full-match result.

## Full-match rerun and animation evidence

The attached-indicator source rerun completed successfully: 1,800 ticks, 30 deployments, result and rematch, passed=true and failures=[] in outputs/Attached-Indicators-Rerun/verification.json. The earlier incomplete capture did not reproduce; its cause remains unknown.

The build diagnostic now separates ground-walk, flight and multi-frame idle samples, records actual observed frame indices per character/clip, and requires all seven characters plus building collapse. This is observed coverage of one seeded match, not proof of all facing/action clips or smooth animation.

## Sprite damage feedback

HP loss now briefly warms the struck sprite, preserving dark contours and current attack playback. The effect fades on gameplay time, holds during pause and clears on rematch; clip changes preserve its strength. East-facing Hoplite guard no longer interrupts a playing action. Native board checks84 and sprite checks47 passed. A90-frame native Hydra damage study was captured; initial pale tint rejected, revised35% highlight with dark-outline protection visually inspected. The existing Windows release predates this source change.

## Living shoreline

Water now has sparse travelling glints and broken surf highlights near painted land/boat edges, using existing water pixels only. Buildings, bridge registration and picking remain unchanged. Native stage13 checks passed, including visible pixel changes across animation times and identical paused frames. Native Water-Glints-Stage.png inspected. Painted boats remain stationary. This source update is newer than the downloadable build.

## Latest delivery — living battlefield

https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-living-battlefield-2026-09-08

Build source fdd441050c4fda2b56f2bc201e235bdc92accd06. Includes attached indicators, damage highlights and shoreline glints. ZIP76,822,485 bytes; SHA256 3D621EE3B8DFF5BFE2522EDAA326A7B892074B2AF23E1F7288E749AA09204B20. Executable SHA256 D77ADCDBF8E3D85E5898CAB114ED0530E18E6F545AF571511E98FDB419A0021E. GitHub ZIP digest matches local.

Full tools/verify.ps1 -Graphics passed after repairing an outdated card-art test that assumed standalone Thunderbolt was an atlas. Native app63, board84, sprites47, stage13, roster79, rules775, full2Dgate and preserved rules suites passed. Separate exported diagnostic passed1800ticks,30placements,7characters,collapse,result and rematch with failures=[]. Evidence outputs/Living-Battlefield-Export-Verification/verification.json.

Release also includes six-second30fps native motion (180frames, no retiming), outputs/Olympus-Living-Battlefield-Motion.mp4. This early exchange shows flight/action and environmental motion, not all ground-walking clips; capture metadata is in outputs/Combined-Polish-Motion/capture.json. Representative frame90 inspected. Remaining locomotion and final-polish requirements above are unchanged.

## Saved presentation preferences

Menu now saves Sound and Animate scenery across launches in user://olympus_preferences.cfg. Disabling scenery holds only water/foliage time; unit actions, combat feedback and authoritative simulation remain active. Re-enabling resumes the held clock. Missing/malformed values use defaults. Native app68 and stage13 checks passed; persistence tests use a unique temporary file and do not modify player preferences. The Windows release above predates this source update.
