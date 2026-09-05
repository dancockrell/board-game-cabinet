extends Control
## Player-facing controller: only observed state enters the 3D scene.
const Session = preload("res://games/ninth_gate/session.gd")
const Board = preload("res://presentation/ninth_gate_board.gd")
const MoveAudio = preload("res://presentation/move_audio.gd")
const SAVE_PATH = "user://ninth-gate-v2.json"
var session = Session.new()
var observed: Dictionary
var orders: Array = []
var selected: String = ""
var mode: String = "move"
var notice: String = "Pick a gold squad, then a glowing tile. Give up to 3 orders."
var cursor := Vector2i(2, 1)
var keyboard_active := false
var board
var surface: SubViewportContainer
var viewport: SubViewport
var details: RichTextLabel
var dispatches: RichTextLabel
var round_label: Label
var status_label: Label
var bark_label: Label
var order_label: Label
var title_label: Label
var commit_button: Button
var heal_button: Button
var help_dialog: AcceptDialog
var sound
var reduced_motion := false
var muted := false
var _animate := false
var _busy := false
var _generation := 0
var _last_report_round := -1

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	_build_ui()
	sound = MoveAudio.new()
	add_child(sound)
	_refresh()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			_capture(argument.trim_prefix("--capture="))

func _build_ui() -> void:
	var skin := Theme.new()
	skin.default_font_size = 17
	skin.set_color("font_color", "Label", Color("eee6d3"))
	skin.set_color("default_color", "RichTextLabel", Color("dddacb"))
	for state in ["normal","hover","pressed","focus","disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("354844") if state == "hover" else Color("233631")
		style.border_color = Color("f8d899") if state == "focus" else Color("52665b")
		style.set_border_width_all(2 if state == "focus" else 1)
		style.set_corner_radius_all(7)
		style.content_margin_left = 10
		style.content_margin_right = 10
		skin.set_stylebox(state,"Button",style)
	theme = skin
	var background := ColorRect.new()
	background.color = Color("0d191a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var art := TextureRect.new()
	var portrait_strip := AtlasTexture.new()
	portrait_strip.atlas = preload("res://assets/ninth_gate/commanders.png")
	portrait_strip.region = Rect2(0,80,2172,350)
	art.texture = portrait_strip
	art.position = Vector2(0,0)
	art.size = Vector2(1440,180)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.size = Vector2(1440,180)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	_label("THE NINTH GATE",Vector2(477,22),37,Color("fff0c8"))
	_label("AURETH  vs  VEYRA",Vector2(576,70),18,Color("e5c891"))
	_label("Beautiful rivals. Terrible neighbours.",Vector2(508,103),18,Color("e8dbcb"))
	_button("Chess cabinet",Vector2(1230,17),Vector2(180,36),func(): get_tree().change_scene_to_file("res://app/main.tscn"))
	_panel(Rect2(22,192,1000,76),Color("1d302e"))
	title_label = _label("TAKE THE THREE BRIDGES",Vector2(42,204),20,Color("e9d499"))
	_label("Hold a bridge to score. First to 12 glory wins, or lead after 8 rounds.",Vector2(42,236),17,Color("d3d9cb"))
	surface = SubViewportContainer.new()
	surface.position = Vector2(22,279)
	surface.size = Vector2(1000,533)
	surface.stretch = true
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.gui_input.connect(_board_input)
	add_child(surface)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1000,533)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	surface.add_child(viewport)
	board = Board.new()
	viewport.add_child(board)
	_panel(Rect2(22,822,1000,116),Color("192a29"))
	status_label = _label("",Vector2(42,836),18,Color("f0d49b"))
	status_label.size = Vector2(958,50)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label("Click a squad → choose a tile → LET THEM CLASH. Your other squads fight automatically.",Vector2(42,892),16,Color("b9cdc2"))
	_label("Arrows + Enter to play  ·  M move  ·  A attack  ·  H heal  ·  R recover  ·  Esc deselect",Vector2(42,917),14,Color("99b3aa"))
	_panel(Rect2(1038,192,380,746),Color("182a29"))
	round_label = _label("",Vector2(1058,207),23,Color("f0d49b"))
	bark_label = _label("Veyra: 'Lovely wings. Try to keep them.'",Vector2(1058,271),16,Color("ecb7ac"))
	bark_label.size = Vector2(340,51)
	bark_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details = RichTextLabel.new()
	details.position = Vector2(1058,330)
	details.size = Vector2(340,144)
	details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(details)
	_button("Move",Vector2(1058,479),Vector2(102,39),func(): _set_mode("move"))
	_button("Strike",Vector2(1172,479),Vector2(102,39),func(): _set_mode("attack"))
	heal_button = _button("Mend",Vector2(1286,479),Vector2(110,39),func(): _set_mode("heal"))
	_button("Recover",Vector2(1058,528),Vector2(160,37),_rally)
	_button("Brace",Vector2(1236,528),Vector2(160,37),func(): _stationary("hold"))
	order_label = _label("",Vector2(1058,578),17,Color("d8d9c7"))
	order_label.size = Vector2(340,75)
	commit_button = _button("LET THEM CLASH",Vector2(1058,665),Vector2(338,52),_commit)
	var gold := StyleBoxFlat.new()
	gold.bg_color = Color("d4b273")
	gold.set_corner_radius_all(7)
	commit_button.add_theme_stylebox_override("normal",gold)
	commit_button.add_theme_color_override("font_color",Color("182623"))
	_button("Undo",Vector2(1058,729),Vector2(100,35),_undo)
	_button("Clear",Vector2(1176,729),Vector2(100,35),func(): orders.clear(); notice="Drafts cleared. Your squads will fight nearby enemies."; _refresh())
	_button("New",Vector2(1294,729),Vector2(102,35),_confirm_new)
	_button("Save",Vector2(1058,775),Vector2(100,35),_save)
	_button("Load",Vector2(1176,775),Vector2(100,35),_load_save)
	_button("How to play",Vector2(1294,775),Vector2(102,35),func(): help_dialog.popup_centered(Vector2i(790,630)))
	var mute := CheckButton.new()
	mute.text = "Sound"
	mute.button_pressed = true
	mute.position = Vector2(1054,819)
	mute.toggled.connect(func(on): muted=not on; sound.set_muted(muted))
	add_child(mute)
	var motion := CheckButton.new()
	motion.text = "Gentle motion"
	motion.position = Vector2(1180,819)
	motion.toggled.connect(func(on): reduced_motion=on)
	add_child(motion)
	dispatches = RichTextLabel.new()
	dispatches.position = Vector2(1058,867)
	dispatches.size = Vector2(338,59)
	dispatches.add_theme_font_size_override("normal_font_size",14)
	add_child(dispatches)
	help_dialog = AcceptDialog.new()
	help_dialog.title = "Three decisions. One glorious mess."
	var manual := RichTextLabel.new()
	manual.custom_minimum_size = Vector2(740,530)
	manual.text = "QUICK START\n\n1. Click a gold squad. Glowing tiles are places it can move.\n2. Click a destination, or Strike and click an enemy. You can change drafts freely.\n3. Give up to three squads an order, then LET THEM CLASH.\n\nOther squads automatically attack nearby enemies. Move orders trade that attack for a better position. Hold bridges with a squad to score glory. A healer can Mend adjacent injured friends; Recover heals itself. Brace trades an attack for protection.\n\nIvory pieces are yours. Ember pieces are Veyra's. Darkened terrain is outside your sight. A plan can miss if its target moves away.\n\nFULL RULES\n\n" + FileAccess.get_file_as_string("res://games/ninth_gate/RULES.md")
	help_dialog.add_child(manual)
	add_child(help_dialog)

func _panel(rect: Rect2,color: Color) -> void:
	var panel := Panel.new()
	panel.position=rect.position
	panel.size=rect.size
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.set_corner_radius_all(9)
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)

func _label(text:String,at:Vector2,font_size:int,color:Color) -> Label:
	var label:=Label.new()
	label.text=text
	label.position=at
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(text:String,at:Vector2,dimensions:Vector2,callback:Callable) -> Button:
	var button:=Button.new()
	button.text=text
	button.position=at
	button.size=dimensions
	button.pressed.connect(callback)
	add_child(button)
	return button

func _refresh() -> void:
	observed=session.view_for("heaven")
	round_label.text="ROUND %s / %s\nYOU %s   ·   VEYRA %s  / %s" % [observed.round,observed.get("round_limit",8),observed.score.heaven,observed.score.hell,observed.get("target_score",12)]
	var text:="SELECT YOUR SQUAD\n\nClick a gold miniature. Move closer, hold a bridge, or set up an attack."
	heal_button.disabled=true
	for unit in observed.units:
		if str(unit.id)==selected:
			text="%s\n%s\n\nHealth %s/%s  ·  Spirit %s\n%s" % [unit.get("display_name",_unit_name(unit)),str(unit.role).capitalize(),unit.hp,unit.max_hp,unit.morale,unit.get("description","")]
			heal_button.disabled=unit.role!="herald"
	details.text=text
	var lines:="%s / 3 ORDERS  ·  %s\n" % [orders.size(),mode.to_upper()]
	for order in orders:
		lines+="%s: %s %s\n" % [_readable_ids(order.unit_id),{"move":"Move","attack":"Strike","heal":"Mend","rally":"Recover","hold":"Brace"}.get(order.type,order.type),_coordinate(order.x,order.y)]
	order_label.text=lines
	if observed.phase=="finished":
		details.text="BATTLE ENDED\n"+str(observed.winner).to_upper()+"\n\n"+("The bridges are yours. Veyra owes you a rematch." if observed.winner=="heaven" else "Veyra takes this round. Try a different opening." if observed.winner=="hell" else "Neither yields. Naturally, both claim victory.")
		bark_label.text="Veyra: 'Same place tomorrow, darling?'"
	commit_button.disabled=_busy or observed.phase=="finished"
	status_label.text=notice
	dispatches.text=_readable_ids("\n".join(observed.log))
	board.show_view(observed,_animate and not reduced_motion)
	board.show_orders(orders,selected,session.legal_orders(selected,"heaven").filter(func(o): return o.type==mode),cursor if keyboard_active else Vector2i(-1,-1))
	_animate=false

func _set_mode(value:String) -> void:
	mode=value
	notice={"move":"Green tiles: move up to two spaces. This squad gives up its automatic attack.","attack":"Orange targets: focus a strike. Enemies may move before the blow lands.","heal":"Blue targets: restore an adjacent friend's health. Select your Herald first."}.get(value,"")
	_refresh()

func _board_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		grab_focus()
		var cell:Vector2i=board.pick_cell(event.position,Vector2(viewport.size))
		if cell.x>=0 and cell.y>=0 and cell.x<12 and cell.y<8:
			_select_cell(cell)

func _gui_input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		keyboard_active=true
		match event.keycode:
			KEY_LEFT: cursor.x=maxi(0,cursor.x-1)
			KEY_RIGHT: cursor.x=mini(11,cursor.x+1)
			KEY_UP: cursor.y=maxi(0,cursor.y-1)
			KEY_DOWN: cursor.y=mini(7,cursor.y+1)
			KEY_ENTER,KEY_SPACE: _select_cell(cursor)
			KEY_M: mode="move"
			KEY_A: mode="attack"
			KEY_H: mode="heal"
			KEY_R: _rally()
			KEY_ESCAPE: selected=""
		_refresh()

func _select_cell(cell:Vector2i) -> void:
	cursor=cell
	if _busy or observed.phase=="finished": return
	if mode=="heal" and selected!="":
		for order in session.legal_orders(selected,"heaven"):
			if order.type=="heal" and order.x==cell.x and order.y==cell.y:
				_draft(order)
				return
	for unit in observed.units:
		if unit.side=="heaven" and unit.x==cell.x and unit.y==cell.y:
			selected=str(unit.id)
			mode="move"
			notice="Choose a glowing tile, Strike a visible enemy, or let this squad fight on its own."
			_refresh()
			return
	for order in session.legal_orders(selected,"heaven"):
		if order.x==cell.x and order.y==cell.y and (order.type==mode or order.type=="attack"):
			_draft(order)
			return
	notice="Select a gold squad first, then choose one of its glowing destinations."
	_refresh()

func _draft(order:Dictionary) -> void:
	if _busy: return
	for index in range(orders.size()-1,-1,-1):
		if orders[index].unit_id==order.unit_id: orders.remove_at(index)
	if orders.size()>=3:
		notice="Three orders ready. Commit them, clear them, or change one of those squads' orders."
	else:
		orders.append(order.duplicate(true))
		notice="Order ready. Keep planning, or LET THEM CLASH. Unordered squads attack automatically."
		sound.pitch_scale=1.15
		sound.play_move_sound()
	_refresh()

func _stationary(type:String) -> void:
	for order in session.legal_orders(selected,"heaven"):
		if order.type==type: _draft(order); return
	notice="Select a gold squad first."
	_refresh()

func _rally() -> void:
	_stationary("rally")

func _commit() -> void:
	if _busy: return
	var result:Dictionary=session.resolve_round(orders,observed.revision)
	if result.get("ok",false):
		orders.clear()
		selected=""
		notice="The field has changed. Hold the bridges, protect your wounded, and make Veyra work for it."
		var quips=["Aureth: 'You could always surrender with style.'","Veyra: 'Careful. I bite back.'","Aureth: 'Eyes on the bridge. Yes, the bridge.'","Veyra: 'That almost looked like a plan.'"]
		bark_label.text=quips[(session.snapshot().round-1)%quips.size()]
		_animate=true
		sound.pitch_scale=0.72
		sound.play_move_sound()
	else:
		notice=str(result.get("error","Those orders could not be accepted."))
	_refresh()

func _undo() -> void:
	if session.undo():
		orders.clear()
		selected=""
		notice="Last round undone. Try another plan."
	_refresh()

func _confirm_new() -> void:
	var dialog:=ConfirmationDialog.new()
	dialog.title="Start a fresh clash?"
	dialog.dialog_text="This replaces the current battle. Save first if you want to keep it."
	dialog.confirmed.connect(func(): _new_battle(); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()

func _new_battle() -> void:
	session.new_game(1824)
	orders.clear()
	selected=""
	mode="move"
	notice="A fresh rivalry. Claim the crossings and keep a squad on each to score."
	bark_label.text="Veyra: 'Lovely wings. Try to keep them.'"
	_refresh()

func _save() -> void:
	var file:=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(session.save_data()))
		notice="Battle saved. Uncommitted plans are not saved."
	else: notice="Could not save the battle."
	_refresh()

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		notice="No saved battle yet."
		_refresh()
		return
	var data=JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if data is Dictionary and session.load_data(data).get("ok",false):
		orders.clear()
		selected=""
		notice="Saved battle restored."
	else: notice="That save could not be loaded. Your current battle is unchanged."
	_refresh()

func _unit_name(unit:Dictionary) -> String:
	return ("H" if unit.side=="heaven" else "D")+str(int(str(unit.id).right(1))+1)

func _readable_ids(text:String) -> String:
	for index in 6: text=text.replace("heaven"+str(index),"H"+str(index+1)).replace("hell"+str(index),"D"+str(index+1))
	return text

func _coordinate(x:int,y:int) -> String:
	return "%s%s" % [String.chr(65+x),y+1]

func _capture(path:String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
