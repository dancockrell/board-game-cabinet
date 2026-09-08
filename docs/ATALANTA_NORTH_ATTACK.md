# Atalanta north attack: eight authored raising, release and lowering poses

The live clip now adds low nocking, bent-elbow draw and shoulder-level draw ahead of the accepted aim/release and three lowering poses. These are independent source drawings. Release moves to .315 seconds (three .075-second raising poses plus .09-second aim); total duration is .630 seconds. The authoritative hit remains synchronized through the Resource strike marker; no rules timing was changed.

Four built-in image-generation edits produced three admitted raising poses and one rejected intermediate with an extra flesh protrusion below the arm, corrected by the fourth edit. Exact prompts, original hashes and admission decisions are in `assets/olympus_arena/sprites/atalanta-north-raising.provenance.json`. All originals are unchanged in local shared `assets/candidates_needing_review/olympus-atalanta-north-raising-2026-09-08`. No paid API, masking, painting or public shared upload.

Native test passes 28 checks including actual chronological texture selection for all eight poses, correct release marker and recovery to canonical rest. A 90-frame 30fps capture and adjacent MP4 are at `outputs/Atalanta-North-Raising`. Low12, bent14, shoulder17, aim19 and release21 were visually inspected in sequence. The head/feet stay registered, and bow/hip quiver/shoulder shawl retain their proper sides. Minor hem and texture differences remain; the low nock still jumps from the canonical angled-bow rest, and the final lowering-to-rest transition needs another intermediate. Eight poses improves the action rather than completing all animation work.

## Previous lowering admission evidence

The previous attack had five independently drawn poses: corrected aim, release, shoulder-level bow lowering, bent-elbow lowering, and relaxed low-arm recovery. The three new drawings preserve left-hand bow, right-hip quiver and left-shoulder shawl. The release marker remains .09 seconds; durations are .09/.075/.075/.075/.09 (total .405 seconds). All sources use the full 1254-square canvas, pivot (675,1067) and scale .708.

Four built-in imagegen calls produced three admitted poses and one rejected midpoint with altered bow shape. Exact prompts, hashes and admission decisions are in `assets/olympus_arena/sprites/atalanta-north-recovery.provenance.json`. All four unchanged originals and manifest are archived locally in shared `assets/candidates_needing_review/olympus-atalanta-north-recovery-2026-09-08`. No paid API, public shared upload, raster masking or painting was used.

Native test passed 21 checks including actual independent recovery textures and return to canonical rest. A 90-frame 30fps Godot study is in `outputs/Atalanta-North-Lowering`; sequential release14, shoulder16, elbow19, low21 and recovered25 were visually inspected. Feet/head remain registered; equipment sides remain stable. The separate normal-speed MP4 uses these native frames.

Remaining work: the lowering is richer, but raising/draw remain short and the final transition to canonical low, tilted-bow rest remains abrupt. Do not describe this as a complete bow animation set.

## Previous anchor admission evidence

Before the lowering expansion, the two-pose attack used independently authored rear aim and release PNGs. The bow remains in anatomical left hand, quiver at right hip and shawl on left shoulder, matching canonical north rest. The old attack's wrong-handed poses are no longer referenced by this Resource. This is a continuity repair, not an eight-pose expansion.

Three built-in image-generation calls produced an accepted isolated aim, a rejected release with a dangling bowstring, and the accepted release with the string repaired. No raster masking, painting or mirroring was used. Full sources remain unchanged in local shared `assets/candidates_needing_review/olympus-atalanta-north-isolated-2026-09-08`; manifest includes exact prompts and separate SHA256.json records hashes. No public shared upload occurred. Only the two admitted PNGs are in the runtime asset tree.

Both source regions are the full 1254-square canvas, with foot-axis pivot (675,1067), scale .708, and durations .09/.15 seconds. Optional strike_time .09 identifies the release boundary for authoritative attack anticipation. The dedicated native test passed 14 checks including actual second-source selection and recovery to rest. A 90-frame native study was captured at 30 fps in `outputs/Atalanta-North-Corrected-Anchor`; rest11, aim12, release15 and recovered20 were visually inspected. Feet/head registration and equipment sides remain stable. Normal-speed MP4 is adjacent to the capture directory.

Remaining work: add raising, draw and lowering poses from these correct anchors. Minor material/outline variation remains; the two-frame transition is still abrupt. The new rear aim is angled upper-left in screen space to show the archery action while retaining the rear view.

## Historical rejected eight-pose expansion


Before the isolated-anchor correction above, the Resource had been restored to its previous two-frame attack. **Do not admit `atalanta-north-attack-eight.png`.** The eight-frame attempt inherited the old attack's incorrect bow hand. Canonical accepted lateral work and the rear rest establish left-hand bow, right-hip quiver and left-shoulder shawl. Fixing the rest to match the wrong attack would spread the defect.

Three initial built-in calls produced eight useful chronological gestures but incorrect equipment ownership. Two additional targeted edits corrected left-hand bow/right-hip quiver, yet the green shawl still changed shoulders between frames and grew into the skirt. Those attempts also remain unadmitted. Exact prompts and hashes are in `ATALANTA_NORTH_ATTACK_REJECTED_PROVENANCE.json` and `ATALANTA_NORTH_ATTACK_CORRECTION.json`; all five originals remain unchanged in the local shared candidate archive `olympus-atalanta-north-attack-eight-2026-09-08`. No public shared upload occurred.

The initial eight-frame native study and passing playback tests proved frame selection and recovery, not acceptable character continuity. They must not be cited as visual approval. The dedicated test now guards exclusion of the rejected sheet and verifies legacy recovery. The review tool captures whichever clip is currently live; old eight-frame output is rejected study evidence.

Next work: author a correct isolated rear left-hand aim anchor, keeping right-hip quiver and left-shoulder shawl visible. Expand from that accepted anchor into low/raise/draw/release/recovery phases rather than inheriting the flawed old attack. The restored two-frame attack retains its pre-existing handedness defect; restoration prevents shipping a newly expanded wrong-handed set and does not resolve that old defect.

Rejected PNG and import sidecar were removed from runtime assets after verifying the shared original SHA-256 F66A8C4D488B91A87CF5FC56F6FA0F197EE041766C91880A4C3E804B4711D0EE. Exact archive source: C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-atalanta-north-attack-eight-2026-09-08/exec-f0799d59-1bcd-4b61-b21b-578df3836a3f.png. Provenance now lives in docs, which the Windows export excludes.

