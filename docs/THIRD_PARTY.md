# Third-party software and asset provenance

The desktop build embeds Godot 4.3, distributed under the MIT license. Its license and bundled third-party notices are retained verbatim in `licenses/GODOT-LICENSE.txt` and `licenses/GODOT-COPYRIGHT.txt`. Copies accompany the Windows build.

Upstream sources:

- https://github.com/godotengine/godot/blob/4.3-stable/LICENSE.txt
- https://github.com/godotengine/godot/blob/4.3-stable/COPYRIGHT.txt

All board and chip geometry, wood and brand shaders, chess-symbol SVGs, and synthesized move audio in this repository were authored for this project. See `assets/PROVENANCE.md` for construction details. No downloaded art packs, fonts, or audio are bundled.

The development oracle was generated with python-chess 1.11.2. The application neither imports nor distributes that Python package. The committed fixture records chess positions and reference results; its generator and source version are retained in tests for reproducibility. Python is unnecessary to execute the checked-in Godot tests.
