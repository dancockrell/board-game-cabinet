# Harpy south claw attack

The south-facing attack now contains eight separately authored drawings: hovering preparation, raised-wing knee bend, tight knee tuck, initial talon projection, full double-claw strike, downstroke follow-through, leg recovery and hover recovery. The old Resource had four entries but only three unique source drawings; its strike drawing was repeated.

The replacement preserves the existing 0.39-second visual playback and changes no rule timing. Strongest claw projection appears at 0.17 seconds. The last two poses restore hanging legs and raised wings before returning to the current eight-pose flight loop.

One built-in image-generation call produced the unchanged source sheet. The exact prompt, original source path and SHA256 are stored beside the PNG in `harpies-south-attack-eight.provenance.json`. An unchanged original and manifest also live in the local shared candidate folder `olympus-harpy-south-attack-eight-2026-09-08`; no candidate was pushed to the public shared repository.

Resource-only irregular crops retain the wide strike wings and exclude neighboring feather tips. Per-frame scales normalize crown-to-belt height against the admitted flight sheet; pivots keep the crown axis stable while the legs tuck. No raster masking, repainting or frame duplication was used.

Validation: Godot4.3 import passed. The dedicated native test checks eight unique crops, chronological timing, preserved duration, double-claw phase, pause, repeated-event rejection and return to flight, with zero failures. The review tool captures 90 native frames at60fps across flight, attack and recovery twice. All eight attack poses were inspected against the painted stage. Initial regular crops included stray neighboring feathers in phases3/7; the corrected captures no longer contain those fragments.

Evidence: `outputs/Harpy-South-Attack-Eight-Final/frame-*.png` and `outputs/Harpy-South-Attack-Eight.mp4` in the workspace. Reproduce with `tools/review_harpy_south_attack.gd -- --capture=<absolute directory>`.

Remaining polish: modest face/torso variation survives between drawings; this is a richer incremental sequence, not complete character animation. The north-facing attack is still the older short sequence. Flight-to-attack starts from the current hover phase and is not an authored transition for every possible wingbeat phase.
