# Atalanta north attack: corrected isolated anchors

The live two-pose attack now uses independently authored rear aim and release PNGs. The bow remains in anatomical left hand, quiver at right hip and shawl on left shoulder, matching canonical north rest. The old attack's wrong-handed poses are no longer referenced by this Resource. This is a continuity repair, not an eight-pose expansion.

Three built-in image-generation calls produced an accepted isolated aim, a rejected release with a dangling bowstring, and the accepted release with the string repaired. No raster masking, painting or mirroring was used. Full sources remain unchanged in local shared `assets/candidates_needing_review/olympus-atalanta-north-isolated-2026-09-08`; manifest includes exact prompts and separate SHA256.json records hashes. No public shared upload occurred. Only the two admitted PNGs are in the runtime asset tree.

Both source regions are the full 1254-square canvas, with foot-axis pivot (675,1067), scale .708, and durations .09/.15 seconds. Optional strike_time .09 identifies the release boundary for authoritative attack anticipation. The dedicated native test passed 14 checks including actual second-source selection and recovery to rest. A 90-frame native study was captured at 30 fps in `outputs/Atalanta-North-Corrected-Anchor`; rest11, aim12, release15 and recovered20 were visually inspected. Feet/head registration and equipment sides remain stable. Normal-speed MP4 is adjacent to the capture directory.

Remaining work: add raising, draw and lowering poses from these correct anchors. Minor material/outline variation remains; the two-frame transition is still abrupt. The new rear aim is angled upper-left in screen space to show the archery action while retaining the rear view.

## Historical rejected eight-pose expansion


Before the isolated-anchor correction above, the Resource had been restored to its previous two-frame attack. **Do not admit `atalanta-north-attack-eight.png`.** The eight-frame attempt inherited the old attack's incorrect bow hand. Canonical accepted lateral work and the rear rest establish left-hand bow, right-hip quiver and left-shoulder shawl. Fixing the rest to match the wrong attack would spread the defect.

Three initial built-in calls produced eight useful chronological gestures but incorrect equipment ownership. Two additional targeted edits corrected left-hand bow/right-hip quiver, yet the green shawl still changed shoulders between frames and grew into the skirt. Those attempts also remain unadmitted. Exact prompts and hashes are in `ATALANTA_NORTH_ATTACK_REJECTED_PROVENANCE.json` and `ATALANTA_NORTH_ATTACK_CORRECTION.json`; all five originals remain unchanged in the local shared candidate archive `olympus-atalanta-north-attack-eight-2026-09-08`. No public shared upload occurred.

The initial eight-frame native study and passing playback tests proved frame selection and recovery, not acceptable character continuity. They must not be cited as visual approval. The dedicated test now guards exclusion of the rejected sheet and verifies legacy recovery. The review tool captures whichever clip is currently live; old eight-frame output is rejected study evidence.

Next work: author a correct isolated rear left-hand aim anchor, keeping right-hip quiver and left-shoulder shawl visible. Expand from that accepted anchor into low/raise/draw/release/recovery phases rather than inheriting the flawed old attack. The restored two-frame attack retains its pre-existing handedness defect; restoration prevents shipping a newly expanded wrong-handed set and does not resolve that old defect.

Rejected PNG and import sidecar were removed from runtime assets after verifying the shared original SHA-256 F66A8C4D488B91A87CF5FC56F6FA0F197EE041766C91880A4C3E804B4711D0EE. Exact archive source: C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-atalanta-north-attack-eight-2026-09-08/exec-f0799d59-1bcd-4b61-b21b-578df3836a3f.png. Provenance now lives in docs, which the Windows export excludes.

