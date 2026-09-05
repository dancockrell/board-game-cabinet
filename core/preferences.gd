extends RefCounted
## Small versioned local preference file, separate from saved game state.
const DEFAULTS: Dictionary = {"muted": false, "flipped": false, "reduced_motion": false, "practice": true}

static func read_settings(path: String) -> Dictionary:
	var settings: Dictionary = DEFAULTS.duplicate()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return settings
	if file.get_length() > 4096:
		file.close()
		return settings
	var parser := JSON.new()
	var error: Error = parser.parse(file.get_as_text())
	file.close()
	if error != OK or not parser.data is Dictionary or parser.data.get("version") != 1:
		return settings
	for key in DEFAULTS:
		if parser.data.get(key) is bool:
			settings[key] = parser.data[key]
	return settings

static func write_settings(path: String, settings: Dictionary) -> Error:
	var payload: Dictionary = {"version": 1}
	for key in DEFAULTS:
		payload[key] = settings.get(key, DEFAULTS[key]) if settings.get(key, DEFAULTS[key]) is bool else DEFAULTS[key]
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(path + ".tmp", path)
