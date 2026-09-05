class_name CabinetEngineAdapter
extends RefCounted
## Adapter response includes its source revision. Session rejects stale responses.
## A future UCI adapter owns process lifetime, cancellation and engine licensing.
func analyze(_state, revision: int) -> Dictionary:
	return {"revision": revision, "move": {}, "provider": "Unavailable", "depth": 0, "candidates": []}
