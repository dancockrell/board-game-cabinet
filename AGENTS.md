# Board Game Cabinet

Rules and game state must extend RefCounted, never Node. Scenes render session state and submit move requests; they never decide legality or patch piece state independently.

Keep chess narrow. Reserve topology and game-definition seams for Xiangqi without implementing universal mechanics prematurely. Themes are Resources; rules cannot import presentation.

Work in independent parallel slices with explicit file ownership. Commit only your owned files, in small coherent increments. The coordinator owns project.godot, app/, core/session.gd, integration, and publication. Never use git add . when another agent is working.

Verify with headless Godot import and test scripts. Capture and inspect the actual rendered board before claiming visual quality. Document incomplete acceptance criteria honestly.
