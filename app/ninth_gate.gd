extends Control
## The map consumes only Heaven's observed view. Draft orders never move counters.
const Session = preload("res://games/ninth_gate/session.gd")
const PALETTE = preload("res://themes/ninth_gate.tres")
const CELL = 73.0
const ORIGIN = Vector2(48, 186)
var session = Session.new()
var observed: Dictionary
var orders: Array = []
var selected: String = ""
var mode: String = "move"
var notice: String = "Select a gold unit, then a destination. Commit up to three orders together."
var details: RichTextLabel
var dispatches: RichTextLabel
var round_label: Label
var help_dialog: AcceptDialog
var cursor := Vector2i(1, 3)
var keyboard_active := false

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	var skin := Theme.new()
	skin.default_font_size = 18
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("36423c") if state == "hover" else Color("242b29")
		style.border_color = Color("d5b96f") if state == "focus" else Color("665d47")
		style.set_border_width_all(2 if state == "focus" else 1)
		style.set_corner_radius_all(4)
		style.content_margin_left = 12
		style.content_margin_right = 12
		skin.set_stylebox(state, "Button", style)
	theme = skin
	_label("THE BOARD GAME CABINET  /  ORIGINAL WAR TABLE", Vector2(48, 30), 16, Color("bbab84"))
	_label("THE NINTH GATE", Vector2(45, 60), 44, Color("eee2c2"))
	_label("Heaven and Hell contest the crossing. An original battle prototype.", Vector2(48, 121), 20, Color("c3c6b7"))
	round_label = _label("", Vector2(990, 65), 26, Color("e0c88f"))
	_button("Chess table", Vector2(1220, 26), Vector2(170, 40), func(): get_tree().change_scene_to_file("res://app/main.tscn"))
	_label("ORDERS TO THE HOST", Vector2(990, 163), 18, Color("cfb67a"))
	details = RichTextLabel.new()
	details.position = Vector2(990, 200)
	details.size = Vector2(400, 220)
	details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(details)
	_button("Move", Vector2(990, 432), Vector2(120, 44), func(): mode = "move"; notice = "Move: choose a highlighted adjacent tile."; _refresh())
	_button("Attack", Vector2(1125, 432), Vector2(120, 44), func(): mode = "attack"; notice = "Attack: choose a highlighted visible enemy."; _refresh())
	_button("Rally", Vector2(1260, 432), Vector2(130, 44), _rally)
	_button("COMMIT ORDERS", Vector2(990, 494), Vector2(400, 54), _commit)
	_button("Clear drafts", Vector2(990, 564), Vector2(190, 42), func(): orders.clear(); _refresh())
	_button("Undo round", Vector2(1200, 564), Vector2(190, 42), _undo)
	_button("Save", Vector2(990, 622), Vector2(120, 40), _save)
	_button("Load", Vector2(1125, 622), Vector2(120, 40), _load_save)
	_button("New battle", Vector2(1260, 622), Vector2(130, 40), _new_battle)
	_label("FIELD DISPATCHES", Vector2(990, 695), 18, Color("cfb67a"))
	dispatches = RichTextLabel.new()
	dispatches.position = Vector2(990, 731)
	dispatches.size = Vector2(400, 178)
	add_child(dispatches)
	_button("How to play", Vector2(48, 884), Vector2(160, 42), func(): help_dialog.popup_centered(Vector2i(770, 600)))
	help_dialog = AcceptDialog.new()
	help_dialog.title = "The Ninth Gate — field manual"
	var manual := RichTextLabel.new()
	manual.custom_minimum_size = Vector2(720, 480)
	manual.text = FileAccess.get_file_as_string("res://games/ninth_gate/RULES.md")
	help_dialog.add_child(manual)
	add_child(help_dialog)
	_refresh()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			_capture(argument.trim_prefix("--capture="))

func _label(text: String, at: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(text: String, at: Vector2, dimensions: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = dimensions
	button.pressed.connect(callback)
	add_child(button)

func _refresh() -> void:
	observed = session.view_for("heaven")
	round_label.text = "ROUND %s / 12\nHEAVEN %s   ·   HELL %s" % [observed.round, observed.score.heaven, observed.score.hell]
	var text := "Your orders: %s / 3  ·  %s\nUnordered units hold their ground.\n\n" % [orders.size(), mode.to_upper()]
	for unit in observed.units:
		if str(unit.id) == selected:
			text += "%s · %s\nStrength %s/%s · Morale %s\n\n" % [_unit_name(unit), unit.role, unit.hp, unit.max_hp, unit.morale]
	for order in orders:
		text += "%s: %s %s\n" % [order.unit_id, order.type, _coordinate(order.x, order.y)]
	if observed.phase == "finished":
		text = "BATTLE ENDED\n%s\n\nFinal scores above. Undo or begin a new battle." % str(observed.winner).to_upper()
	details.text = _readable_ids(text)
	dispatches.text = _readable_ids("\n".join(observed.log.slice(maxi(0, observed.log.size() - 8))))
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("111917"))
	draw_rect(Rect2(970, 148, 440, 790), Color("19211f"))
	draw_style_box(_frame(), Rect2(28, 165, 916, 628))
	if not observed:
		return
	var visible: Array = observed.visible_cells
	for y in 8:
		for x in 12:
			var at := ORIGIN + Vector2(x, y) * CELL
			var terrain: String = observed.terrain[y * 12 + x]
			draw_rect(Rect2(at, Vector2.ONE * CELL), PALETTE.terrain_color(terrain))
			if terrain == "wood":
				for index in 3:
					var p := at + Vector2(19 + index * 17, 30 + (index % 2) * 14)
					draw_colored_polygon(PackedVector2Array([p + Vector2(0,-15),p + Vector2(-12,12),p + Vector2(12,12)]), Color("2e483b"))
			elif terrain == "hill":
				draw_arc(at + Vector2(36,40), 23, PI, TAU, 20, Color("c0b68f"), 2)
				draw_arc(at + Vector2(36,40), 15, PI, TAU, 20, Color("c0b68f"), 2)
			elif terrain == "bridge":
				for plank in 5:
					draw_line(at + Vector2(10, 12 + plank*12), at + Vector2(63, 12 + plank*12), Color("68583f"), 2)
			elif terrain == "river":
				for wave in 3:
					draw_line(at+Vector2(17,17+wave*18),at+Vector2(55,21+wave*18),Color("65838a"),1)
			draw_rect(Rect2(at, Vector2.ONE * CELL), Color(0.12,0.17,0.14,0.3), false, 1)
			if not _is_visible(visible, x, y):
				draw_rect(Rect2(at, Vector2.ONE * CELL), Color(0.03,0.08,0.09,0.48))
	for site in observed.sites:
		var center := ORIGIN + Vector2(site.x + 0.5, site.y + 0.5) * CELL
		draw_arc(center, 29, 0, TAU, 40, Color("ecd394"), 2)
		_text(center + Vector2(-6, -18), "+", 22, Color("ffe2a0"))
	if selected != "" and observed.phase != "finished":
		for order in session.legal_orders(selected, "heaven"):
			if order.type == mode:
				var at := ORIGIN + Vector2(order.x, order.y)*CELL
				draw_rect(Rect2(at+Vector2(3,3),Vector2.ONE*(CELL-6)), Color("f2d999") if mode=="move" else Color("ffad8b"),false,3)
	for unit in observed.units:
		var center := ORIGIN + Vector2(unit.x + 0.5, unit.y + 0.5)*CELL
		var heaven: bool = unit.side == "heaven"
		var token := Rect2(center-Vector2(27,22),Vector2(54,44))
		draw_rect(Rect2(token.position+Vector2(3,5),token.size),Color(0,0,0,0.35))
		draw_rect(token,PALETTE.heaven if heaven else PALETTE.hell)
		draw_rect(token,Color("fff0ba") if str(unit.id)==selected else Color("493f32"),false,2)
		_text(center+Vector2(-22,-2),_unit_name(unit),14,Color("292c25") if heaven else Color("ffe0c1"))
		_text(center+Vector2(-22,16),"%s  %s" % [str(unit.role).left(3).to_upper(),unit.hp],13,Color("292c25") if heaven else Color("ffe0c1"))
	for order in orders:
		for unit in observed.units:
			if str(unit.id)==str(order.unit_id):
				var start := ORIGIN+Vector2(unit.x+0.5,unit.y+0.5)*CELL
				var end := ORIGIN+Vector2(order.x+0.5,order.y+0.5)*CELL
				draw_line(start,end,Color("ffdf7e"),3,true)
				draw_circle(end,5,Color("ffdf7e"))
	for x in 12:
		_text(ORIGIN+Vector2(x*CELL+30,-8),String.chr(65+x),14,Color("d3c5a0"))
	for y in 8:
		_text(ORIGIN+Vector2(-17,y*CELL+42),str(y+1),14,Color("d3c5a0"))
	if keyboard_active:
		draw_rect(Rect2(ORIGIN+Vector2(cursor)*CELL+Vector2(6,6),Vector2.ONE*(CELL-12)),Color.WHITE,false,2)
	_text(Vector2(48,825),"GOLD: HEAVEN    RED: HELL    +: SACRED SITE    DIMMED: OUTSIDE SIGHT",16,Color("c0ba9f"))
	_text(Vector2(48,857),notice.left(105),16,Color("e8d8ac"))
	_text(Vector2(229,912),"Arrows + Enter: board   ·   M / A / R: order type   ·   Esc: clear selection",16,Color("aab7ab"))

func _frame() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("4b382a")
	box.border_color = Color("8d7451")
	box.set_border_width_all(3)
	box.set_corner_radius_all(10)
	return box

func _text(at: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)

func _is_visible(cells: Array, x: int, y: int) -> bool:
	return (y*12+x) in cells or Vector2i(x,y) in cells or [x,y] in cells or {"x":x,"y":y} in cells

func _coordinate(x: int, y: int) -> String:
	return "%s%s" % [String.chr(65+x),y+1]

func _unit_name(unit: Dictionary) -> String:
	return ("H" if unit.side == "heaven" else "D") + str(int(str(unit.id).right(1)) + 1)

func _readable_ids(text: String) -> String:
	for index in 6:
		text = text.replace("heaven"+str(index), "H"+str(index+1)).replace("hell"+str(index), "D"+str(index+1))
	return text

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := Vector2i((event.position - ORIGIN)/CELL)
		if Rect2(ORIGIN,Vector2(12,8)*CELL).has_point(event.position):
			grab_focus()
			_select_cell(cell)
	if event is InputEventKey and event.pressed:
		keyboard_active = true
		match event.keycode:
			KEY_LEFT: cursor.x = maxi(0,cursor.x-1)
			KEY_RIGHT: cursor.x = mini(11,cursor.x+1)
			KEY_UP: cursor.y = maxi(0,cursor.y-1)
			KEY_DOWN: cursor.y = mini(7,cursor.y+1)
			KEY_ENTER, KEY_SPACE: _select_cell(cursor)
			KEY_M: mode = "move"
			KEY_A: mode = "attack"
			KEY_R: _rally()
			KEY_ESCAPE: selected = ""
		_refresh()

func _select_cell(cell: Vector2i) -> void:
	cursor = cell
	if observed.phase == "finished":
		return
	for unit in observed.units:
		if unit.side == "heaven" and unit.x == cell.x and unit.y == cell.y:
			selected = str(unit.id)
			_refresh()
			return
	if selected == "":
		notice = "Select one of your gold units first."
		queue_redraw()
		return
	for order in session.legal_orders(selected,"heaven"):
		if order.type == mode and order.x == cell.x and order.y == cell.y:
			_draft(order)
			return
	notice = "No legal %s order there. Choose a highlighted tile." % mode
	queue_redraw()

func _draft(order: Dictionary) -> void:
	for index in range(orders.size()-1,-1,-1):
		if orders[index].unit_id == order.unit_id:
			orders.remove_at(index)
	if orders.size() >= 3:
		notice = "Three orders drafted. Clear drafts or replace an existing unit's order."
	else:
		orders.append(order.duplicate(true))
		notice = "Order drafted. Counters move only when both armies' orders resolve."
	_refresh()

func _rally() -> void:
	for order in session.legal_orders(selected,"heaven"):
		if order.type == "rally":
			_draft(order)
			return
	notice = "Select a unit that can rally."
	queue_redraw()

func _commit() -> void:
	var result: Dictionary = session.resolve_round(orders,observed.revision)
	if result.get("ok",false):
		orders.clear()
		selected = ""
		notice = "Orders resolved. Review the field dispatches, then plan your next round."
	else:
		notice = str(result.get("error","Orders rejected."))
	_refresh()

func _undo() -> void:
	if session.undo():
		orders.clear()
		selected = ""
		notice = "Previous round restored, including the random sequence."
	_refresh()

func _new_battle() -> void:
	session.new_game(1824)
	orders.clear()
	selected = ""
	notice = "A fresh battle. Same starting seed for reproducible practice."
	_refresh()

func _save() -> void:
	var file := FileAccess.open("user://ninth-gate-v1.json",FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(session.save_data()))
		notice = "Battle saved. Draft orders are not saved."
	else:
		notice = "Could not write the save file."
	queue_redraw()

func _load_save() -> void:
	if not FileAccess.file_exists("user://ninth-gate-v1.json"):
		notice = "No saved battle found."
		queue_redraw()
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string("user://ninth-gate-v1.json"))
	if data is Dictionary:
		var result = session.load_data(data)
		if (result is Dictionary and result.get("ok",false)) or (result is bool and result):
			orders.clear()
			selected = ""
			notice = "Saved battle restored."
		else:
			notice = "Save rejected; the active battle is unchanged."
	else:
		notice = "No readable save found; the active battle is unchanged."
	_refresh()

func _capture(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
