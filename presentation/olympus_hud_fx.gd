extends Control
## Match presentation layered over the 3D viewport. It observes snapshots only.

var _banner := ""
var _banner_age := 99.0
var _banner_duration := 1.5
var _flash := Color(1, 1, 1, 0)
var _flash_age := 99.0
var _sparks: Array[Dictionary] = []
var _last_towers: Dictionary = {}
var _last_phase := ""
var _last_overtime := false
var _double_announced := false
var _last_event_id := -1
var _last_elapsed := -1.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)

func reset() -> void:
	_banner = ""
	_banner_age = 99.0
	_flash_age = 99.0
	_sparks.clear()
	_last_towers.clear()
	_last_phase = ""
	_last_overtime = false
	_double_announced = false
	_last_event_id = -1
	_last_elapsed = -1.0
	queue_redraw()

func show_countdown(text: String) -> void:
	_banner = text
	_banner_age = 0.0
	_banner_duration = 0.92
	queue_redraw()

func deployed(at: Vector2) -> void:
	_flash = Color(0.22, 0.72, 1.0, 0.16)
	_flash_age = 0.0
	for i in 14:
		var angle := TAU * float(i) / 14.0
		_sparks.append({"position":at, "velocity":Vector2(cos(angle), sin(angle)) * (75.0 + i * 4.0), "age":0.0, "life":0.48, "color":Color("7bdcff")})
	while _sparks.size() > 84: _sparks.pop_front()
	queue_redraw()

func consume_state(state: Dictionary) -> void:
	var elapsed := float(state.get("elapsed", 0.0))
	if elapsed < _last_elapsed or (elapsed <= 0.001 and not _last_towers.is_empty()):
		reset()
	_last_elapsed = elapsed
	for event in state.get("events", []):
		var event_id := int(event.get("id", -1))
		if event_id <= _last_event_id: continue
		_last_event_id = event_id
		if str(event.get("kind", "")) == "charge_ready":
			show_banner("YOUR MINOTAUR IS CHARGED" if int(event.get("side", 1)) == 0 else "RIVAL MINOTAUR CHARGED", 1.05)
	for tower in state.get("towers", []):
		var id := str(tower.id)
		var hp := float(tower.hp)
		if _last_towers.has(id) and float(_last_towers[id]) > 0.0 and hp <= 0.0:
			_flash = Color(1.0, 0.58, 0.23, 0.28)
			_flash_age = 0.0
			show_banner("TEMPLE SHATTERED" if str(tower.kind) == "temple" else "TOWER FALLEN", 1.8)
		_last_towers[id] = hp
	if not _double_announced and float(state.get("elapsed", 0.0)) >= 120.0:
		_double_announced = true
		show_banner("DOUBLE ELIXIR", 1.8)
	if bool(state.get("overtime", false)) and not _last_overtime:
		show_banner("SUDDEN DEATH", 2.0)
	_last_overtime = bool(state.get("overtime", false))
	_last_phase = str(state.get("phase", ""))

func show_banner(text: String, duration := 1.5) -> void:
	_banner = text
	_banner_age = 0.0
	_banner_duration = duration
	queue_redraw()

func advance(delta: float) -> void:
	_banner_age += delta
	_flash_age += delta
	for spark in _sparks:
		spark.age += delta
		spark.position += spark.velocity * delta
		spark.velocity *= exp(-delta * 4.0)
	for spark in _sparks.duplicate():
		if spark.age >= spark.life: _sparks.erase(spark)
	queue_redraw()

func _draw() -> void:
	if _flash_age < 0.42:
		var alpha := _flash.a * (1.0 - _flash_age / 0.42)
		draw_rect(Rect2(Vector2.ZERO, size), Color(_flash.r, _flash.g, _flash.b, alpha))
	for spark in _sparks:
		var alpha := 1.0 - float(spark.age) / float(spark.life)
		var color: Color = spark.color
		color.a = alpha
		draw_circle(spark.position, 3.0 + alpha * 4.0, color)
	if _banner_age < _banner_duration:
		var progress := _banner_age / _banner_duration
		var alpha := minf(1.0, _banner_age * 8.0) * minf(1.0, (_banner_duration - _banner_age) * 5.0)
		var scale_value := lerpf(1.35, 1.0, minf(1.0, progress * 4.0))
		var font := ThemeDB.fallback_font
		var font_size := 46
		var text_size := font.get_string_size(_banner, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var center := size * Vector2(0.5, 0.43)
		var panel := Rect2(center - Vector2(text_size.x * 0.64, 43), Vector2(text_size.x * 1.28, 82))
		draw_style_box(_banner_box(alpha), panel)
		draw_set_transform(center, 0.0, Vector2.ONE * scale_value)
		draw_string(font, Vector2(-text_size.x / 2.0, 15), _banner, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1.0, 0.88, 0.57, alpha))
		draw_set_transform(Vector2.ZERO)

func _banner_box(alpha: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.025, 0.105, 0.15, alpha * 0.90)
	box.border_color = Color(0.86, 0.63, 0.27, alpha)
	box.set_border_width_all(2)
	box.set_corner_radius_all(14)
	box.shadow_color = Color(0, 0, 0, alpha * 0.45)
	box.shadow_size = 10
	return box
