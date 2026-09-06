# Hoplite source reuse trial

Current method: reuse and pose the preserved textured Hoplite instead of further primitive construction or additional microtexture passes. No new generation, purchases or credits.

Source: work/art-source/olympus/authored-v001/hoplite.glb, SHA256 aa5443f30fd1c87268d92a0e7f2257458b85eaf7098d63b7f5335b1e7652bbe9. Existing generated-source provenance remains in GENERATED_3D_WORKFLOW.md. This source is not CC0.

The review tool now supports --ready-pose, lowering the upper arms and bringing forearms forward through the existing skeleton. Source bytes are unchanged. Native source faces +X, not the viewer's +Z: the arena comparison corrects orientation. Bounds are evaluated after posing before scale and floor alignment. Comparison uses the actual arena renderer and lighting, with a close camera by default and --game-scale for ordinary camera size.

Native comparison shows much better adult proportions, armor layering and painted identity. Open spear grip remains conspicuous; spear orientation, fingers and shield attachment require mesh/weight cleanup. No authored walk/attack clips exist. Do not ship this static pose as an animated replacement. No playable roster changed in this trial.

Next bounded work: inspect weapon and hand vertex influences, isolate weapon as a rigid attachment, close finger pose without crushing the hand, then author a short idle/walk/thrust test. Compare in movement and both team directions before admission. Preserve raw model and derive any edited GLB separately. Do not generate another roster until this one model passes.

Validation: native four-view pose renders and arena comparison scripts executed successfully. This is visual development evidence, not runtime regression or performance acceptance. Model remains 17,246 triangles and one material.

## Motion investigation

`tools/hoplite_motion_trial.gd` now captures a deterministic 120-frame, 30 fps skeleton trial: two seconds of walking and two of arm attack motion. It is a diagnostic, not an authored gameplay animation. Native selected-frame review exposed that the source's Left arm chain controls the visible spear arm. Finger curl now targets that side's named finger chains.

A 90-degree wrist turn badly distorts the spear. Rejected and removed that pose; do not hide the defect with camera choice. Weapon must be isolated and rigidly bound before convincing thrust motion. The retained trial keeps the transverse spear, so it is explicitly not an accepted attack.

`tools/inspect_hoplite_connectivity.py` provides a read-only indexed mesh component audit. Source has 233 indexed components; these may include UV/normal seams and must not be treated as 233 semantic parts. Positional welding and spatial inspection are required before selecting spear vertices. Source GLB remains unchanged.

Native final diagnostic completed successfully (120 frames). No live roster change or new Windows release. No credits used. Remaining acceptance: rigid weapon attachment, convincing grip, planted feet, shoulder deformation and an attack directed toward its target.
