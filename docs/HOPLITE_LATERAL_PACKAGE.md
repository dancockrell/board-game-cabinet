# Hoplite lateral marching package

New `hoplite_east_walk.tres` and `hoplite_west_walk.tres` are looping resources ready for the coordinator's locomotion selection. No shared board/actor logic changed in this slice.

Source uses independent drawings, with upright spear and blue owl shield. Sequence is contact, far knee lifted, shared contact, near knee lifted. Three distinct authored poses per direction; this is a provisional march, not a complete four-contact-phase walk. The attempted second correction regressed to duplicate legs and was not admitted.

Frame bounds are irregular source strips, with per-frame ground anchors. Scale 2.0 at pixel_size .0027 approximates the existing hoplite's crest-to-foot height. The source remains untouched; runtime keying preserves pale tunic details.

Validation: Godot 4.3 headless import successful. `tools/review_hoplite_lateral.gd` renders 60 native frames of both directions and asserts both Resource contracts. Inspected frames 6 and 14 show opposite raised feet, intact spear tips, keyed edges, and stable ground height. Video is `outputs/Hoplite-Lateral-Walk.mp4` outside the repo. This staged review does not establish live-match animation or final motion quality.
