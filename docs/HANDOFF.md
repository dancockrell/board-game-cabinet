# Current roster animation integration - 2026-09-08

All seven roster characters now have at least one drawn defeat: twelve clips and96drawings. New since the creature release: AtalantaN/S16,MinotaurN8,HopliteS8. HopliteS comes from a repaired complete32drawing batch; originals and exactprompts remain in art_batches/hoplite_batch_02 and the local shared candidate folder. MinotaurS andHopliteN remain unadmitted due to weapon continuity. Lateral facings retain previous feedback.

Board integration checks all12clips, all8poses perclip, grounding, pause, authoritative removal, lifetime and clearing unfinished falls on rematch. Native controlled battlefield evidence is outputs/Roster-Drawn-Defeat-Board.mp4. The individual Hoplite comparison preserves full spear/shield and matches standing height, with broader shoulders than canonical art. Character admission reports describe remaining visual limitations.

This source update follows the Windows creature release below; do not confuse source admission with a newer verified package. Native combat review identified allied Harpy overlap, shrine occlusion, and a small on-screen playfield. See CREATURE_COMBAT_REVIEW.md; further readability work remains.

# Current creature collapse integration — 2026-09-08

Hydra, Heracles and Harpies now join Medusa with eight drawn defeat poses in each north/south facing: 64 admitted drawings across eight clips. The newest 48 drawings come from existing complete batch sheets, copied unchanged. Other characters and lateral directions retain their prior departure effect.

Authoritative removal creates only a cosmetic actor lasting .78 seconds. Harpy flight lift descends in world space, reaching ground at .22 seconds south or .31 north; the drawing pivots retain ground contact. Pause holds animation, and no defeated actor remains in rules state. The board integration test covers all eight clips, every pose, scale, starting placement, final grounding, authority and bounded lifetime. Native battlefield capture: outputs/Creature-Drawn-Defeat-Board.mp4. Inspected mid/final frames show intact bodies and grounded Harpies. This controlled removal study does not establish crowded-combat polish or full-match balance.

Playable Windows checkpoint: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-creature-defeats-2026-09-08 . Source6229583. Local executable: outputs/Olympus-Creature-Defeats-Windows/Olympus.exe. Full native verifier passed. Exported1800-tick match passed30legaldeployments,sevencharacters,result/rematch and196drawndefeat samples; failures empty. This match observed MedusaN/S,HarpyN/S,HeraclesS andHydraS; dedicated board tests cover the other north clips and everyframe. Engine log has no script errors. ZIP SHA256: FBDEDC1610BF2E082E8121544B8CDCE67AC2B1CFD2E1926E5366BB1EE15E75F4. Resource-level details are in HYDRA_DEFEAT.md, HERACLES_DEFEAT_ADMISSION.md and HARPIES_DEFEAT.md. Earlier entries below describe historical checkpoints; their counts and coverage do not describe this newest integration.

# Olympus Arena handoff â€” 2D only

Updated 2026-09-08. Private repository: https://github.com/dancockrell/board-game-cabinet

## Active authority

The user explicitly requested removal of 3D artwork. All active artwork must be 2D: authored pixel sprites, painted backgrounds, flat effects and interface drawings. No sculpted figures, modeled scenery, PBR materials, or model fallback may be introduced. Follow AGENTS.md and OLYMPUS_BOARD_ART.md. Older releases and archived documents are historical, not design authority.

The orthographic Node3D/Sprite3D coordinate infrastructure only places flat artwork and resolves picking. It does not contain or authorize volumetric artwork. Rules and authoritative state remain RefCounted and independent of presentation.

## Current checkpoint: drawn defeats, bridge flow and creature batches

Two batch waves now contain28current sheets across allsevencharacters:896requested cells and891visible sourcefigures. Repairs are separate, not additionalcoverage. These are not891distinctapproved poses. Medusa north/south defeat rows now contribute16runtime-admitted drawings; the other rows remain candidates for measured crop/continuity review. Harpies/Minotaur/Hydra each gained four full sheets in wave2. Wider cells require aspect-ratio planning:4x8 on a square canvas gives2:1cells;4x8 on1:2portrait gives squarecells.

Medusa's authoritative removal now starts the matching eight-pose fall on a separate cosmetic actor. Pause freezes it; no rules unit persists; final dissolve occurs at the end of .78seconds. Other characters and lateral directions retain their previous departure effect. Full native verifier passed, and the exported match observed56drawndefeat samples across both admitted directions, with no engine script errors.

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-drawn-defeats-2026-09-08
Source: `82e87be961bc7b2ee3b162729ea4f88fa3d724be`.
Package: `Olympus-Drawn-Defeat-Windows.zip`,148,382,934bytes.
ZIP SHA256: `D4C307C8EBE228EDA27D906C0DD7D4E9E9F3A3D89354CF12AE2DA7EAE9A28AFF`.
Executable SHA256: `72C06516C92F70702DE3F1BA5F663A76A1105312741D1D8BD5FEFD4080E323E6`.
The package includes notices, provenance, report and engine log. Exported verification passed1800ticks/30legaldeployments/allsevencharacters/buildingcollapse/results/rematch. The accelerated .1second report samples defeatframes1-7; dedicated native board tests/review cover all8, including frame0. Candidate art_batches are excluded from export. This is a development checkpoint, not final art or balance approval.

## Earlier batch-production wave and source status

The owner now requests full sprite sheets in large batches, building toward thousands of drawings. Follow CHARACTER_BATCH_PRODUCTION.md. The first wave produced sixteen current directional/action sheets across Hoplites, Atalanta, Heracles and Medusa: 512 requested cells, 511 visible candidate figures. One additional Heracles west repair sheet is preserved separately and is not additional coverage. These are not 511 unique approved frames; runtime admission is zero pending per-row crop/continuity checks. Native previews and exact prompts/hashes are in art_batches and local shared candidates. Candidate batches are explicitly excluded from Windows export.

Current accepted runtime source also includes Atalanta north twelve poses (.930 seconds, release .465), Heracles west eight evenly timed gait phases and Medusa south seven gait drawings. Full battlefield review exposed allied bridge-entry deadlock: all three soldiers now cross using legal deck width rather than competing for the center. Regression covers both bridges and both armies. Prepared-target comparison normalizes numeric unit IDs and string tower IDs, fixing a runtime type error exposed by the now-flowing formations.

The local Olympus-Bridge-Flow-Windows build opened for the user predates that ID-comparison fix and is NOT a newly published or fully accepted release. Its accelerated match report alone did not catch engine script errors; full source verification remains the stronger error gate. The last published Windows checkpoint remains expanded-motion below. Do not confuse current source/batch candidates with that download.

Next: admit coherent hurt/defeat rows to actual event playback, then batch the remaining creature roster. Use wider four-column/eight-row sheets for long weapons where narrow cells cause overlap. Current character departure still dissolves the last pose; authored character defeat must be integrated before claiming it is finished.

## Current implementation

Seven sprite character types: Hoplites, Atalanta, Medusa, Minotaur, Heracles, Hydra, Harpies. All have authored attacks; Hydra now has four idle/attack facings. Ground walking coverage remains incomplete for some lateral views. Pixel card portraits match deployed characters. Thunderbolt uses its flat illustrated symbol.

The modeled stage is replaced by an original painted pixel-art background. Painted bridge centers register to authoritative lanes x=-2.7 and x=2.7. A second flat image layer extends sea at wide aspect ratios. Image shaders animate water and leaf colors on the pause-aware clock. Boats and border props are painted/static. Buildings remain sprite clips; collapse/departure debris, projectiles and trails are flat drawings. Team indicators are flat outlines.

Old model makers, 3D scenery materials, GLB tools, chess/Ninth Gate 3D apps and graphical tests are removed. Their rules, sessions and notation foundations remain parked. There is no menu path to those retired scenes.

## Global removal status

The 2026-09-08 owner decision applies to every project and shared pack: 2D artwork only. Delete retired 3D assets rather than preserve them for a future return. Reuse the shared 2D art folder across Olympus, Cattle Trail, DR Companion and Pirate Island. Physical removal outside this checkout is pending: automatic approval review rejected deletion with only "blocked by policy". Do not describe an inventory or a catalog exclusion as completed deletion.

No GLB/GLTF/FBX/BLEND/OBJ files remain in the project work directory. Legacy copies in the shared library, other project checkouts, old build outputs and historical releases require separate removal. Current 2D sources, candidates and reference art remain valuable and are not deletion targets. The earlier archive-for-later decision is superseded.

## Source update after the prepared-attacks Windows checkpoint

The source now expands Atalanta's north attack from two to five drawings, adding three authored bow-lowering recovery poses while preserving the .09-second release marker. Heracles now has four independently drawn westward walking poses connected to authoritative board movement. Medusa's north walk expands from two to six selected gait drawings. These are actual new drawings, not duplicated timing cells or mirrored equipment.

Attack cancellation releases its facing lock before locomotion chooses direction, preventing a one-tick wrong-facing transition after target loss. Dedicated native tests cover the new resources and Heracles west board playback; all new tests are registered in the standard verifier.

Remaining art work: Heracles still needs intermediate gait drawings and better rest continuity; Atalanta needs raising/draw poses and a smoother last lowering-to-rest transition; Medusa needs richer upper-body and snake motion. Four- and six-pose foundations are progress, not final smooth-animation approval. These changes are included in the expanded-motion Windows checkpoint below.

## Source update after expanded-motion download

Atalanta north attack now has eight independent drawings: low nock, bent draw, shoulder draw, aim, release and three lowering poses. Total duration .630 seconds; the release marker is .315 seconds. A rules-driven board test confirms this longer setup still shows release on the authoritative hit and leaves damage unchanged.

Heracles west walk now has seven unique drawings in .72 seconds, adding heel landing, opposite weight acceptance and forward swing. One missing far-leg forward-swing pose still leaves an asymmetric longer passing hold. Medusa south walk now has six distinct contact/passing/reach drawings in .64 seconds, with bent knees in passing. More upper-body motion, smoother rest transitions and further intermediates remain needed.

Native motion studies: Atalanta-North-Raising.mp4, Heracles-West-Seven-Poses.mp4 and Medusa-South-Six-Walk.mp4 under workspace outputs. Dedicated tests cover every source pose and board transitions. These newer source changes are not in the expanded-motion Windows download below.

## Previous Windows checkpoint: expanded character motion

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-expanded-motion-2026-09-08

Source: `8162fb03703e158e2aaf265ba41f4327caf7a492`. Package: `Olympus-Expanded-Motion-Windows.zip` (130,754,123 bytes).
ZIP SHA256: `84EC61B45379AC13B432E43223052F7091B2413AB4A930F1824A4034DAFC5A94`; remote release digest verified identical.
Executable SHA256: `C3F1B0A566EC35EE8A605A99EB8621E50ED8F1CE8CCF0AD2F6456D86E872359E`.

Export built from an isolated committed-source archive. Full native source verifier passed. Exported verification passed 1800 ticks, 30 legal deployments, seven character types, 13 collapse samples, result and rematch. All five Atalanta north attack frames and six Medusa north walk frames were observed. Heracles west was covered by dedicated source board tests rather than this match. Package includes notices, provenance, build notes and the exported verification report. Release also includes Atalanta lowering and Medusa walk native motion studies.

More animation authoring remains active; this is a playable development checkpoint, not final art approval.

## Previous Windows checkpoint: prepared attacks and character continuity

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-prepared-attacks-2026-09-08

Source: `d6fc6ea1c55eeb0985095728cb0764dcac87ab66`. Package: `Olympus-Prepared-Attacks-Windows.zip` (122,087,435 bytes).
ZIP SHA256: `C38CEBA8751EBF7EAD270610730928B430E5283B405D5D64F447482E6B88C7A0`.
Executable SHA256: `E71C5B6330C41F69B0E733A96FC1E2B16FAC3C1259AB3880CB5BE252CA78DE37`.

Heracles east movement now uses four alternating contact/passing drawings, with native board movement and stopped recovery verified. West remains unfinished. Atalanta north aim/release now keep the bow in her left hand, quiver at right hip and shawl on left shoulder, matching the canonical rest. These are two corrected isolated anchors, not an eight-pose expansion. See HERACLES_LATERAL_REVIEW.md and ATALANTA_NORTH_ATTACK.md.

The rules expose their chosen in-range target for presentation. Supported clips use that target and remaining cooldown to prepare before a hit, hold before contact, then commit on the authoritative event. Enabled for Hoplite east, Harpy south and Atalanta north/south attacks. Damage, attack intervals and legal movement are unchanged. Immediate first strikes without earlier in-range cooldown retain direct playback; limited time can skip early setup. See ATTACK_PREPARATION.md for exact boundaries and remaining cosmetic projectile timing.

Full graphical verification passed: preparation 59, Heracles east 14 plus board integration, corrected Atalanta north 14, sprite 67, continuity 20, board 85, stage 13, roster 79, app 68, effects 337, arena 775 and preserved rules suites. Integrated 2D gate: seven kinds, 30 legal placements, 959 effect samples and 6,740 planar drawings, zero failures. The exported executable passed 1,800 ticks, 30 deployments, all seven types, 13 collapse samples, result/rematch and zero failures. Native exported battle capture inspected.

Native evidence includes a 100-frame Heracles board study at 30 fps, a 90-frame corrected Atalanta study at 30 fps, and 180 frames of rules-driven attack preparation at 60 fps. Final timing record selects contact pose 9 at action time 0.335 when target HP falls from 640 to 616. These videos are controlled motion studies, not full-match footage. Package includes notices, provenance and the exported verification report.

Remaining: Heracles west movement and additional inbetweens, richer bow actions, a coherent north Harpy strike, broader action coverage, crowd readability and balance. Heracles arm/club motion remains restrained; Atalanta rear attack is still short. The new north Harpy sheet attempts were rejected and archived outside runtime assets. This is a playable checkpoint; the full quality goal remains active.

## Historical Windows checkpoint: drawn collapse and Harpy attack

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-drawn-collapse-2026-09-08

Source: `1e867dfde8fb3c1ecc8f37035b76d690839d5c50`. Package: `Olympus-Drawn-Collapse-Windows.zip` (115,637,416 bytes).
ZIP SHA256: `06DDD9C4BC01B523DB82CDC20B965F3698A0C18CAAEFCA368283E5A81D0DEF1E`.
Executable SHA256: `685BFCE1B3AF1047745A36B3BFAAE292673A3F405C04B148718E5F0C4C3B2D29`.

Eight authored shrine collapse drawings replace squash animation, followed by the original permanent rubble drawing. Explicit stair pivots and uniform per-frame scale preserve placement. The temporary collapse covers the transition; permanent ruins appear afterward. Large generic explosion rings/smoke were removed because they hid the masonry. See SHRINE_AUTHORED_COLLAPSE.md.

Harpy south attack expands from three unique drawings/four entries to eight distinct phases while preserving0.39-second playback. See HARPY_SOUTH_ATTACK.md. Earlier richer walks, wingbeats, Hoplite thrust and saved preferences remain included.

Full graphical verification passed: collapse170, event-driven attack132, Harpy dedicated checks, board85, sprite67, continuity20, stage13, roster79, app68, effects337, arena775 and preserved rules suites. Integrated 2D gate: seven kinds,30legalplacements,959effectsamples,6740planar drawings,zero failures. Native60fps studies inspected all new collapse/Harpy stages. Exported executable passed1800ticks,30legaldeployments,seven types,13collapse samples,result/rematch,zero failures; exported collapse capture inspected. Videos are isolated motion studies, not normal-speed full-match footage.

Atalanta front/rear attack expansion attempts were not admitted: equipment/clothing continuity failed. The original two-frame attacks remain, including the known legacy rear handedness defect. Rejected north artwork was physically removed from runtime assets after verifying its unchanged shared archive; its provenance is in excluded docs. Do not cite the intermediate eight-frame native study as accepted art. See ATALANTA_NORTH_ATTACK.md and ATALANTA_SOUTH_ATTACK_REVIEW.md.

Remaining: correct isolated Atalanta aim anchors before expanding bow actions, richer Heracles lateral locomotion, broader combat poses, fine gait/wing transitions and crowd readability. Minor rubble rearrangement and Harpy face/torso variation remain. The goal is still active; this is a playable development checkpoint.

## Historical Windows checkpoint: expanded walks and wingbeats

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-expanded-walks-2026-09-08

Source: `a3fde440388bf87f6d9b0072c8cd450d0d361464`. Package: `Olympus-Expanded-Walks-Windows.zip` (112,297,164 bytes).
ZIP SHA256: `917741BE7E17FD2457F3A1E34C95400A23B763CB90828E96709FE8EE9EF6F162`.
Executable SHA256: `B27AB1105B3A54153A5D77D0D621D0E7980E2287B2269FEB325840D52465D2E3`.

Atalanta east and west each have eight independently authored walking poses, preserving equipment handedness. Six east poses received separately generated skin-shading corrections. Both Harpy flight directions now have eight wingbeat drawings. Unit health indicators sit above authored silhouettes in the camera plane, including flight lift. The package retains prior richer Hoplite and Hydra clips, animated water/surf, collapse effects and saved preferences.

Full graphical verification passed: Atalanta lateral41, west22, east/west board tests covering all eight source frames, board85, sprite67, continuity20, stage13, roster79, app68, effects337, arena775 and preserved rules suites. Integrated 2D gate: seven kinds,30 legal placements,963 effect samples,6756 planar drawings,zero failures.

The exported executable passed1800 ticks,30 legal deployments,seven kinds,13 collapse samples,result/rematch,zero failures. It observed all eight Atalanta east and Harpy flight phases,seven of eight west phases; dedicated native board tests cover all eight west phases. Native exported battle and90-frame Atalanta motion review were inspected. The attached Atalanta video is a native30fps isolated study, not full-match footage.

Remaining: richer Heracles lateral walking, more combat poses, arm/braid counter-motion, finer gait transitions and crowd readability. Rejected Heracles guides remain studies, not runtime art. This is a playable checkpoint, not final quality acceptance.

## Historical Windows checkpoint: richer sprites

Release: https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-richer-sprites-2026-09-08

Source: `9958b5705ea4e99fd97ea71f2671d9e89f80afee`. Package: `Olympus-Richer-Sprites-Windows.zip` (82,603,904 bytes).
ZIP SHA256: `4B0652D3412DA1E2F4A2973805C5FB6407853EE42D4E4BD105BD086EDCB2E82B`.
Executable SHA256: `973E272DF23C3E6ECD273D3F72B0EE69EEB28C650ED023C893A66B2E09B5C06E`.

Hoplite east attack now contains seventeen distinct source poses including spear raising/lowering; Hydra north/south each have eight-pose walking clips connected to movement. Source sheets stay intact, using per-frame pivots and optional calibrated absolute frame scales. Saved sound/scenery settings are included. See RICHER_SPRITES_2026-09-08.md for admission and remaining defects.

Full graphical verification passed: sprite67, continuity20, board84, stage13, roster79, app68, effects337, arena775 and preserved rule suites. Native north/south Hydra checks exercise all eight frames, movement positions and idle recovery. The integrated 2D gate inspected seven kinds,30 legal placements,963 effect samples and6756 planar drawings with no failures.

The exported executable completed1800 ticks,30 legal deployments,all seven types,13 collapse samples,result and rematch; passed=true,failures=[]. Its accelerated sampling observes six Hoplite attack phases and all eight Hydra south frames. It does not cover every action/direction; dedicated native clip/board tests and motion reviews supply the new-frame coverage. The package includes notices, per-source provenance, BUILD-NOTES.md, VALIDATION.md and VERIFICATION.json. The release's Hoplite video is a native30fps motion study, not full-match footage.

Remaining: richer Atalanta and Heracles walking, other short action/direction sequences, finer Hydra limb/tail transitions, broader combat readability and balance polish. The rear Hydra gait is an exaggerated stomp. No claim of final art approval or completed game quality. This checkpoint is superseded by the expanded-walks package above.

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

## Idle playback repair ï¿½ 2026-09-08

Standing actors now advance their authored idle clips. Idle facing changes preserve normalized phase; attack recovery applies only time after the action ends, and pause/rematch preserve or clear clocks respectively. Native sprite checks passed (45) and motion continuity checks passed (20). The standard graphical verification now includes motion continuity. This source change is newer than the Windows checkpoint above; that executable does not include this repair.

## Hydra lateral steps ï¿½ 2026-09-08

Added separate east/west four-pose authored walk Resources. Movement selects them; standing uses idle playback, attacks retain authoritative event timing. Built-in generation plus one background-only correction; original chroma source preserved. Four ordered native poses inspected on the battlefield, resource timing checks and integrated 2D gate passed. North/south locomotion and smoother in-betweens remain unfinished. This is newer source than the downloadable Windows checkpoint.

Atalanta east/west four-pose walks are now connected to movement (native clip tests: 16 passed). Contact poses remain similar and lifted steps exaggerated; smoother intermediate poses remain required. Heracles lateral generation was rejected for repeated planted feet; see HERACLES_LATERAL_REVIEW.md. No claim of complete locomotion coverage.

## Latest Windows delivery ï¿½ animated sprites

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

## Latest delivery ï¿½ living battlefield

https://github.com/dancockrell/board-game-cabinet/releases/tag/olympus-living-battlefield-2026-09-08

Build source fdd441050c4fda2b56f2bc201e235bdc92accd06. Includes attached indicators, damage highlights and shoreline glints. ZIP76,822,485 bytes; SHA256 3D621EE3B8DFF5BFE2522EDAA326A7B892074B2AF23E1F7288E749AA09204B20. Executable SHA256 D77ADCDBF8E3D85E5898CAB114ED0530E18E6F545AF571511E98FDB419A0021E. GitHub ZIP digest matches local.

Full tools/verify.ps1 -Graphics passed after repairing an outdated card-art test that assumed standalone Thunderbolt was an atlas. Native app63, board84, sprites47, stage13, roster79, rules775, full2Dgate and preserved rules suites passed. Separate exported diagnostic passed1800ticks,30placements,7characters,collapse,result and rematch with failures=[]. Evidence outputs/Living-Battlefield-Export-Verification/verification.json.

Release also includes six-second30fps native motion (180frames, no retiming), outputs/Olympus-Living-Battlefield-Motion.mp4. This early exchange shows flight/action and environmental motion, not all ground-walking clips; capture metadata is in outputs/Combined-Polish-Motion/capture.json. Representative frame90 inspected. Remaining locomotion and final-polish requirements above are unchanged.

## Saved presentation preferences

Menu now saves Sound and Animate scenery across launches in user://olympus_preferences.cfg. Disabling scenery holds only water/foliage time; unit actions, combat feedback and authoritative simulation remain active. Re-enabling resumes the held clock. Missing/malformed values use defaults. Native app68 and stage13 checks passed; persistence tests use a unique temporary file and do not modify player preferences. The Windows release above predates this source update.


