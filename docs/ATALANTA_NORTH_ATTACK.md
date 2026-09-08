# Atalanta north attack: eight authored phases

The north-facing shot now uses eight distinct source drawings: nocked low bow, raising, drawing, aim, release, follow-through, intermediate lowering, and lowered recovery. The nonlooping sequence lasts 0.66 seconds; release begins at 0.34 seconds. These are presentation timings only and never apply damage or decide legal actions.

Three built-in image-generation calls produced the unchanged 1536 x 1024 source sheet. The second corrected a front-facing torso and removed arrows after release. The third supplied a genuine intermediate lowering pose. Exact prompts, source hashes, and selection are in `assets/olympus_arena/sprites/atalanta-north-attack-eight.provenance.json`. Originals are also retained locally under shared candidates `olympus-atalanta-north-attack-eight-2026-09-08`; no shared public upload was performed.

Regions use explicit boundaries and foot pivots. The last column begins at x=1136 because a uniform grid clips its left foot and leaks that foot into the adjacent frame. The solid magenta backing is removed by the established runtime shader; the source PNG was never painted or destructively masked by a script.

Validation: native dedicated test 14 checks, zero failures; central actual-board attack-sequence test 182 checks, zero failures at this checkpoint. A 90-frame native review runs two attacks with rest before and after; source phases and recovery were inspected sequentially. Capture folder: `outputs/Atalanta-North-Eight-Attack` in the parent workspace. Review command: Godot --path . --script tools/review_atalanta_north_attack.gd -- --capture=<absolute folder>.

Acceptance limits: this expands useful action drawings substantially, but the legacy north rest holds the bow in the opposite hand from the legacy north attack and this matching expansion. The rest-to-attack transition therefore still needs a coherent replacement rest/turn pose. Bow hand is consistent inside this attack. Minor feet/cloth shifts remain; there is no nocking-from-quiver sequence. This is an incremental production improvement, not final character-animation approval.
