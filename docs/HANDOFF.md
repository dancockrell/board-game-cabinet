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

## Verified Windows checkpoint

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
