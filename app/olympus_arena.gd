extends Control
## Real-time controller. Fixed simulation ticks own every placement and hit.
const Session = preload("res://games/olympus_arena/session.gd")
const Arena = preload("res://presentation/olympus_arena_board.gd")
const MoveAudio = preload("res://presentation/olympus_audio.gd")
var session = Session.new()
var board
var state: Dictionary = {}
var catalog: Dictionary = {}
var viewport: SubViewport
var surface: SubViewportContainer
var selected_slot := -1
var started := false
var paused := false
var _accumulator := 0.0
var _dragging := false
var _last_pointer := Vector2(-999,-999)
var _textures: Dictionary = {}
var cards: Array = []
var timer_label: Label
var score_label: Label
var energy_label: Label
var energy_bar: ProgressBar
var next_label: Label
var selection_label: Label
var description_label: Label
var notice_label: Label
var match_label: Label
var card_preview: TextureRect
var battle_overlay: Panel
var overlay_title: Label
var overlay_text: Label
var start_button: Button
var pause_button: Button
var sound
var muted := false
var notice := "Choose a card, then click your half of the arena. You can also drag cards."

func _ready() -> void:
	catalog = session.catalog()
	_build_ui()
	sound = MoveAudio.new()
	add_child(sound)
	_refresh()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			_capture(argument.trim_prefix("--capture="))

func _build_ui() -> void:
	var theme_ := Theme.new()
	theme_.default_font_size = 18
	theme_.set_color("font_color", "Label", Color("f8ecd0"))
	for name_ in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("34586a") if name_ == "hover" else Color("172f40")
		style.border_color = Color("ffe0a0") if name_ in ["focus", "pressed"] else Color("96794c")
		style.set_border_width_all(2)
		style.set_corner_radius_all(12)
		style.shadow_color = Color(0,0,0,0.45)
		style.shadow_size = 6
		style.shadow_offset = Vector2(0,4)
		theme_.set_stylebox(name_, "Button", style)
	theme = theme_
	var bg := ColorRect.new()
	bg.color = Color("091e2a")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# The arena fills the central stage; information stays outside the deployment surface.
	_panel(Rect2(264,68,912,710), Color("987f51"))
	surface = SubViewportContainer.new()
	surface.position = Vector2(270,74)
	surface.size = Vector2(900,698)
	surface.stretch = true
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.gui_input.connect(_arena_input)
	surface.mouse_exited.connect(func(): _last_pointer=Vector2(-999,-999); board.clear_preview())
	add_child(surface)
	viewport = SubViewport.new()
	viewport.size = Vector2i(900,698)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	surface.add_child(viewport)
	board = Arena.new()
	viewport.add_child(board)
	_label("OLYMPUS",Vector2(25,16),34,Color("f5d390"))
	_label("A R E N A",Vector2(29,56),15,Color("a5c5cb"))
	_panel(Rect2(580,9,280,54),Color("152f3e"))
	timer_label = _label("3:00",Vector2(616,13),32,Color("fff0cd"))
	match_label = _label("PRACTICE MATCH",Vector2(719,31),12,Color("a9d7dd"))
	_button("Chess cabinet",Vector2(1220,22),Vector2(194,42),func(): get_tree().change_scene_to_file("res://app/main.tscn"))
	_panel(Rect2(20,108,225,612),Color("102936"))
	_label("YOUR CHAMPIONS",Vector2(36,124),15,Color("b9a272"))
	card_preview = TextureRect.new()
	card_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	card_preview.position = Vector2(31,158)
	card_preview.size = Vector2(203,270)
	card_preview.clip_contents = true
	card_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card_preview)
	selection_label = _paragraph("Pick your opening",Vector2(36,447),Vector2(195,64),25)
	selection_label.add_theme_color_override("font_color",Color("ffdda0"))
	description_label = _paragraph("",Vector2(36,519),Vector2(193,123),17)
	_label("1–4  SELECT    •    DRAG TO PLAY",Vector2(33,679),11,Color("97b6be"))
	_panel(Rect2(1194,108,225,280),Color("102936"))
	_label("TEMPLE CLASH",Vector2(1212,129),15,Color("b9a272"))
	score_label = _label("YOU 0 : 0 RIVAL",Vector2(1212,169),21,Color("ffdda0"))
	_label("BLUE  /  YOUR ARMY",Vector2(1212,217),15,Color("7bbefd"))
	_label("RED  /  RIVAL ARMY",Vector2(1212,246),15,Color("ff9180"))
	_paragraph("Break the enemy temple.
Or take more towers.",Vector2(1212,304),Vector2(185,66),17)
	_panel(Rect2(1194,405,225,193),Color("102936"))
	_label("UP NEXT",Vector2(1212,423),13,Color("b9a272"))
	var next_art := TextureRect.new()
	next_art.name = "NextArt"
	next_art.position = Vector2(1212,456)
	next_art.size = Vector2(72,96)
	next_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	next_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	next_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(next_art)
	next_label = _paragraph("",Vector2(1294,470),Vector2(107,74),19)
	_label("Cards cycle after every play",Vector2(1212,570),12,Color("97b6be"))
	pause_button = _button("Pause",Vector2(1194,620),Vector2(105,43),_toggle_pause)
	_button("Restart",Vector2(1310,620),Vector2(109,43),_restart_confirm)
	var mute := CheckButton.new()
	mute.text = "Sound"
	mute.button_pressed = true
	mute.position = Vector2(1230,681)
	mute.toggled.connect(func(on): muted = not on; sound.set_muted(muted))
	add_child(mute)
	_panel(Rect2(264,785,912,168),Color("102733"))
	for slot in 4:
		var button := Button.new()
		button.position = Vector2(473+slot*134,791)
		button.size = Vector2(124,132)
		button.pivot_offset = Vector2(62,132)
		button.clip_contents = true
		button.gui_input.connect(func(event): _card_input(event,slot))
		button.pressed.connect(func(): _select_card(slot))
		add_child(button)
		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		icon.position = Vector2(4,4)
		icon.size = Vector2(116,103)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		var name_label := Label.new()
		name_label.position = Vector2(3,107)
		name_label.size = Vector2(118,23)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size",16)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(name_label)
		var cost_bg := Panel.new()
		cost_bg.position = Vector2(7,6)
		cost_bg.size = Vector2(32,35)
		cost_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gem := StyleBoxFlat.new()
		gem.bg_color = Color("863bc5")
		gem.border_color = Color("efbbff")
		gem.set_border_width_all(2)
		gem.set_corner_radius_all(12)
		cost_bg.add_theme_stylebox_override("panel",gem)
		button.add_child(cost_bg)
		var cost_label := Label.new()
		cost_label.position = Vector2(14,7)
		cost_label.add_theme_font_size_override("font_size",23)
		cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(cost_label)
		cards.append({"button":button,"icon":icon,"name":name_label,"cost":cost_label})
	energy_bar = ProgressBar.new()
	energy_bar.position = Vector2(379,931)
	energy_bar.size = Vector2(708,12)
	energy_bar.max_value = 10
	energy_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("c37af1")
	fill.set_corner_radius_all(6)
	energy_bar.add_theme_stylebox_override("fill",fill)
	add_child(energy_bar)
	energy_label = _label("5 / 10",Vector2(289,843),24,Color("e9b5ff"))
	_label("ELIXIR",Vector2(291,879),13,Color("b4a0cc"))
	notice_label = _paragraph("",Vector2(25,747),Vector2(215,176),16)
	battle_overlay = _panel(Rect2(445,290,550,294),Color("102b3e"))
	overlay_title = _label("ENTER THE ARENA",Vector2(480,317),30,Color("ffdda0"))
	overlay_text = _paragraph("Four cards. Two lanes. One temple to break.\n\nChoose a card and deploy on the blue half.\nYour troops take it from there.",Vector2(480,374),Vector2(480,120),19)
	start_button = _button("BATTLE",Vector2(580,510),Vector2(280,50),_start_or_restart)
	var battle_style := StyleBoxFlat.new()
	battle_style.bg_color = Color("b7792d")
	battle_style.border_color = Color("ffe0a0")
	battle_style.set_border_width_all(2)
	battle_style.set_corner_radius_all(12)
	start_button.add_theme_stylebox_override("normal",battle_style)

func _panel(rect:Rect2,color:Color) -> Panel:
	var panel:=Panel.new()
	panel.position=rect.position
	panel.size=rect.size
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.border_color=Color("5d665b")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel",style)
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	return panel

func _label(text:String,at:Vector2,font_size:int,color:Color) -> Label:
	var label:=Label.new()
	label.text=text
	label.position=at
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _paragraph(text:String,at:Vector2,dimensions:Vector2,font_size:int) -> Label:
	var label:=Label.new()
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.position=at
	label.size=dimensions
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("d0e0e8"))
	label.text=text
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

func _process(delta:float) -> void:
	if started and not paused and state.get("phase","")=="playing":
		_accumulator+=minf(delta,0.25)
		var changed:=false
		while _accumulator>=0.1:
			session.tick()
			_accumulator-=0.1
			changed=true
		if changed: _refresh()

	for slot in cards.size():
		var button: Button = cards[slot].button
		var active: bool = slot == selected_slot
		button.position.y = lerpf(button.position.y, 779.0 if active else 791.0, 1.0-exp(-delta*18.0))
		button.scale = button.scale.lerp(Vector2.ONE * (1.045 if active else 1.0),1.0-exp(-delta*18.0))
	if selected_slot >= 0 and _last_pointer.x > -900: _preview(_last_pointer)
	if board and not state.is_empty(): board.show_state(state,delta)

func _refresh() -> void:
	state=session.snapshot()
	if sound: sound.consume_state(state)
	var seconds:=maxi(0,int(ceil(float(state.time_remaining))))
	timer_label.text="%d:%02d" % [seconds/60,seconds%60]
	match_label.text="DOUBLE ELIXIR" if float(state.elapsed)>=120 else "PRACTICE MATCH"
	if state.get("overtime",false): match_label.text="SUDDEN DEATH"
	var crowns:=[0,0]
	for tower in state.towers:
		if tower.hp<=0: crowns[1-int(tower.side)]+=3 if tower.kind=="temple" else 1
	score_label.text="YOU %s  :  %s RIVAL" % [crowns[0],crowns[1]]
	energy_label.text="%s / 10" % int(floor(state.energy[0]))
	energy_bar.value=state.energy[0]
	get_node("NextArt").texture = _texture(state.get("next_card","hoplites"))
	next_label.text=catalog.get(state.get("next_card",""),{}).get("name","-")
	for slot in 4:
		var kind:String=state.hand[slot]
		var card:Dictionary=catalog[kind]
		cards[slot].icon.texture=_texture(kind)
		cards[slot].name.text=card.name
		cards[slot].cost.text=str(card.cost)
		cards[slot].button.tooltip_text=card.description
		cards[slot].button.modulate=Color("ffe9b2") if slot==selected_slot else Color.WHITE if state.energy[0]>=card.cost else Color("8496a7")
		cards[slot].button.disabled=state.phase=="finished"
	if selected_slot>=0:
		var kind:String=state.hand[selected_slot]
		selection_label.text=catalog[kind].name+" Â· "+str(catalog[kind].cost)
		description_label.text=catalog[kind].description
		card_preview.texture=_texture(kind)
	else:
		selection_label.text="Choose your next card" if started else "Pick your opening"
		description_label.text="Select a card below, then click your half of the arena. Your troops will move and fight automatically."
		card_preview.texture=_texture(state.hand[0])
	notice_label.text=notice
	if state.phase=="finished":
		paused=false
		selected_slot=-1
		_show_overlay(true)
		overlay_title.text="VICTORY!" if state.winner==0 else "DEFEAT" if state.winner==1 else "DRAW"
		overlay_text.text="Towers taken: %s â€” %s\n\n" % [crowns[0],crowns[1]]+("Your heroes have conquered the arena." if state.winner==0 else "Try a different push. Save elixir for defense." if state.winner==1 else "The temples stand. Settle it in a rematch.")
		start_button.text="REMATCH"
	board.show_state(state,0.0)

func _texture(kind:String) -> Texture2D:
	if not _textures.has(kind):
		var order := ["hoplites","atalanta","minotaur","medusa","heracles","hydra","harpies","thunderbolt"]
		var index := order.find(kind)
		if index < 0: return null
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://assets/olympus_arena/card-atlas-v1.png")
		atlas.region = Rect2((index % 4)*384,(index / 4)*512,384,512)
		atlas.filter_clip = true
		_textures[kind] = atlas
	return _textures[kind]

func _show_overlay(show:bool) -> void:
	for control in [battle_overlay,overlay_title,overlay_text,start_button]: control.visible=show

func _start_or_restart() -> void:
	if state.phase=="finished": session.new_game(42)
	started=true
	paused=false
	_accumulator=0
	selected_slot=-1
	pause_button.text="Pause"
	_show_overlay(false)
	notice="Pick a card, then deploy on your blue half."
	_refresh()

func _select_card(slot:int) -> void:
	if state.phase=="finished": return
	selected_slot=slot
	notice="Deploy %s on your half." % catalog[state.hand[slot]].name
	if state.hand[slot]=="thunderbolt": notice="Aim Thunderbolt anywhere in the arena."
	_refresh()

func _card_input(event:InputEvent,slot:int) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		_select_card(slot)
		_dragging=true

func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_1,KEY_2,KEY_3,KEY_4]: _select_card(event.keycode-KEY_1)
		elif event.keycode==KEY_ESCAPE:
			selected_slot=-1
			board.show_deployment(Vector2.INF,false)
			_refresh()
		elif event.keycode==KEY_SPACE: _toggle_pause()
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed and _dragging:
		_dragging=false
		var local:Vector2=event.position-surface.global_position
		if Rect2(Vector2.ZERO,surface.size).has_point(local): _deploy_at(local)

func _arena_input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_pointer=event.position
		_preview(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		_deploy_at(event.position)

func _preview(local:Vector2) -> void:
	if selected_slot<0 or not started or paused or state.phase!="playing":
		board.show_deployment(Vector2.INF,false)
		return
	var point:Vector2=board.pick_ground(local,Vector2(viewport.size))
	var valid:bool=session.preview_deploy(selected_slot,point).get("ok",false)
	board.show_deployment(point,valid,state.hand[selected_slot]=="thunderbolt",state.hand[selected_slot])

func _deploy_at(local:Vector2) -> void:
	if not started:
		notice="Press BATTLE to begin."
		_refresh()
		return
	if paused or selected_slot<0 or state.phase!="playing": return
	var point:Vector2=board.pick_ground(local,Vector2(viewport.size))
	var result:Dictionary=session.deploy(selected_slot,point)
	if result.get("ok",false):
		selected_slot=-1
		board.show_deployment(Vector2.INF,false)
		sound.pitch_scale=1.2
		sound.play_move_sound()
		notice="Deployed! Your hand has cycled. Build your next push."
	else: notice=str(result.get("error","You cannot deploy there."))
	_refresh()

func _toggle_pause() -> void:
	if not started or state.phase=="finished": return
	paused=not paused
	pause_button.text="Resume" if paused else "Pause"
	notice="Paused. Press Space or Resume to continue." if paused else "Battle resumed."
	_refresh()

func _restart_confirm() -> void:
	var was_paused:=paused
	paused=true
	var dialog:=ConfirmationDialog.new()
	dialog.title="Start a new match?"
	dialog.dialog_text="The current match will be replaced."
	dialog.confirmed.connect(func(): session.new_game(42); started=false; paused=false; selected_slot=-1; _accumulator=0; _show_overlay(true); overlay_title.text="ENTER THE ARENA"; overlay_text.text="New match ready. Choose your opening."; start_button.text="BATTLE"; _refresh(); dialog.queue_free())
	dialog.canceled.connect(func(): paused=was_paused; dialog.queue_free())
	add_child(dialog)
	dialog.popup_centered()

func _capture(path:String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
