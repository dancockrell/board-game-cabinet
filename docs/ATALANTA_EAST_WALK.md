# Atalanta east walking production contract

The east walk now contains eight individually generated phase drawings: contact, weight transfer, passing, extension, then those four phases with opposite leg support. These are eight authored images, not repeated timings or a mirrored four-frame clip. West also has eight independently authored phases; see ATALANTA_WEST_WALK.md.

Broad sheet generation repeatedly failed to alternate legs. Single-pose work kept the upper-body identity stable. A temporary yellow-near/blue-far leg guide made the layering explicit; restoring natural colors established the opposite contact. Passing and extension were then generated from those isolated poses. The first compressed poses dipped too deeply in native playback and were replaced with shallower bends.

Source PNGs remain unchanged. The existing SpriteClip Resource selects one source per frame, explicit measured head-axis/ground pivots and absolute scale. Each phase lasts 0.10 seconds; the loop is 0.8 seconds. Per-frame scales calibrate the two corrected source drawings without repainting or resampling their source files. Gameplay authority and action selection are unchanged.

Validation: clean Godot 4.3 import; native `tests/test_atalanta_lateral_walk.gd` passed 33 checks including ordered source selection, looping, shooting recovery and stopped facing. `tools/review_atalanta_lateral_walk.gd` produced 90 native frames at 30 fps; all east phases were inspected. This isolated visual review is not a substitute for the coordinator's board/full-match check.

Six color-corrected source variants now replace the excessive far-leg shadow with warm skin shading. Their original poses remain archived unchanged; ancestry and hashes are in atalanta-east-tone.provenance.json. A native 90-frame review checked the combined east/west clips. Remaining art work: add arm and braid counter-motion and improve transition cadence. Eight poses are a useful increase, not a claim of finished animation quality. The corrected down pose has restrained compression rather than the initial pronounced crouch.

The shared original-source archive and ancestry are recorded in `assets/olympus_arena/sprites/atalanta-lateral-walk-provenance.json`. Rejected guides and overcompressed poses stay out of the runtime Resource. Do not substitute one of those candidates based only on matching filenames or having more cells.

