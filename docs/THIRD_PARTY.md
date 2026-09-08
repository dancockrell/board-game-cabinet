# Third-party software and asset provenance

The Windows build embeds Godot 4.3 under the MIT license. Its verbatim license and bundled notices are retained in `licenses/GODOT-LICENSE.txt` and `licenses/GODOT-COPYRIGHT.txt`, and accompany the build.

Upstream: https://github.com/godotengine/godot/blob/4.3-stable/LICENSE.txt and https://github.com/godotengine/godot/blob/4.3-stable/COPYRIGHT.txt.

The active game uses authored/generated 2D pixel artwork. Source sheets and adjacent provenance records identify generation tools, hashes, atlas crops and transformations. Generated output is not asserted to be CC0. Synthesized audio and rendering code were authored for this project. Historical 3D material maps and model builders were archived outside the project and removed on 2026-09-08; their earlier provenance remains in the shared archive.

The development chess oracle was generated with python-chess 1.11.2. The application neither imports nor distributes that Python package. Committed fixtures record positions and reference results; the generator remains for reproducibility. Python is unnecessary to run the checked-in Godot tests.
