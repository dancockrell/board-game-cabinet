extends Control
## Real-time controller. Fixed simulation ticks own every placement and hit.
const Session = preload("res://games/olympus_arena/session.gd")
const Arena = preload("res://presentation/olympus_arena_board.gd")
const MoveAudio = preload("res://presentation/olympus_audio.gd")
const HudFx = preload("res://presentation/olympus_hud_fx.gd")
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
var _card_frames: Dictionary = {}
var hud_fx
var _countdown_remaining := 0.0
var _countdown_number := 0
var drag_proxy: TextureRect
var timer_label: Label
var score_label: Label
var energy_label: Label
var energy_bar: ProgressBar
var next_label: Label
var selection_label: Label
var notice_label: Label
var match_label: Label
var battle_overlay: Panel
var overlay_title: Label
var overlay_text: Label
var start_button: Button
var pause_button: Button
var sound
var muted := false
var notice := ""

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
	
	surface = SubViewportContainer.new()
	surface.position = Vector2(0,54)
	surface.size = Vector2(1440,724)
	surface.stretch = true
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	surface.gui_input.connect(_arena_input)
	surface.mouse_exited.connect(func(): _last_pointer=Vector2(-999,-999); board.clear_preview())
	add_child(surface)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1440,724)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	surface.add_child(viewport)
	board = Arena.new()
	viewport.add_child(board)
	hud_fx = HudFx.new()
	hud_fx.position = surface.position
	hud_fx.size = surface.size
	add_child(hud_fx)
	_label("OLYMPUS",Vector2(24,15),19,Color("cfbb91"))
	timer_label = _label("3:00",Vector2(681,8),30,Color("fff0cd"))
	match_label = _label("",Vector2(794,20),13,Color("a9d7dd"))
	score_label = _label("YOU 0 : 0 RIVAL",Vector2(467,18),17,Color("d6dfe0"))
	pause_button = _button("Pause",Vector2(1200,8),Vector2(90,38),_toggle_pause)
	var menu := MenuButton.new()
	menu.name = "MatchMenu"
	menu.text = "Menu"
	menu.position = Vector2(1302,8)
	menu.size = Vector2(112,38)
	add_child(menu)
	menu.get_popup().add_item("Restart match",0)
	menu.get_popup().add_check_item("Sound",1)
	menu.get_popup().set_item_checked(1,true)
	menu.get_popup().add_separator()
	menu.get_popup().add_item("Chess cabinet",2)
	menu.get_popup().id_pressed.connect(func(id):
		match id:
			0: _restart_confirm()
			1:
				muted = not muted
				sound.set_muted(muted)
				menu.get_popup().set_item_checked(1,not muted)
			2: get_tree().change_scene_to_file("res://app/main.tscn")
	)
	# The hand owns card identity and tooltips; no duplicate portrait sidebar.
	_card_frames = {
		"normal": _card_frame(Color("8e7d5a"), Color("122630"), 1),
		"hover": _card_frame(Color("c8b17d"), Color("1c3540"), 2),
		"selected": _card_frame(Color("ffe3a2"), Color("263944"), 3),
		"waiting": _card_frame(Color("435762"), Color("101f29"), 1),
	}
	selection_label = _paragraph("",Vector2(447,779),Vector2(560,26),16)
	selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var next_art := TextureRect.new()
	next_art.name = "NextArt"
	next_art.position = Vector2(1030,835)
	next_art.size = Vector2(48,64)
	next_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	next_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	next_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(next_art)
	_label("NEXT",Vector2(1030,812),12,Color("97b6be"))
	next_label = _paragraph("",Vector2(1090,850),Vector2(135,45),14)
	for slot in 4:
		var button := Button.new()
		button.position = Vector2(447+slot*140,808)
		button.size = Vector2(124,132)
		button.pivot_offset = Vector2(62,132)
		button.clip_contents = true
		button.add_theme_stylebox_override("hover", _card_frames.hover)
		button.add_theme_stylebox_override("pressed", _card_frames.selected)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("disabled", _card_frames.waiting)
		button.gui_input.connect(func(event): _card_input(event,slot))
		button.pressed.connect(func(): _select_card(slot))
		add_child(button)
		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		icon.position = Vector2(5,5)
		icon.size = Vector2(114,100)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		var name_label := Label.new()
		name_label.position = Vector2(3,106)
		name_label.size = Vector2(118,23)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size",15)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(name_label)
		var cost_bg := Panel.new()
		cost_bg.position = Vector2(9,9)
		cost_bg.size = Vector2(30,30)
		cost_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gem := StyleBoxFlat.new()
		gem.bg_color = Color("653190")
		gem.border_color = Color("dba7f6")
		gem.set_border_width_all(1)
		gem.set_corner_radius_all(15)
		cost_bg.add_theme_stylebox_override("panel",gem)
		button.add_child(cost_bg)
		var cost_label := Label.new()
		cost_label.position = Vector2(9,9)
		cost_label.size = Vector2(30,30)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cost_label.add_theme_font_size_override("font_size",20)
		cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(cost_label)
		cards.append({"button":button,"icon":icon,"name":name_label,"cost":cost_label,"cost_style":gem})
	drag_proxy = TextureRect.new()
	drag_proxy.size = Vector2(104, 138)
	drag_proxy.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_proxy.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	drag_proxy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_proxy.modulate = Color(1, 1, 1, 0.88)
	drag_proxy.visible = false
	add_child(drag_proxy)
	energy_bar = ProgressBar.new()
	energy_bar.position = Vector2(447,946)
	energy_bar.size = Vector2(544,5)
	energy_bar.max_value = 10
	energy_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("c37af1")
	fill.set_corner_radius_all(2)
	energy_bar.add_theme_stylebox_override("fill",fill)
	add_child(energy_bar)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("30263d")
	track.set_corner_radius_all(3)
	energy_bar.add_theme_stylebox_override("background",track)
	energy_bar.size = Vector2(544,5)
	energy_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Nine dividers reveal ten equal charges without a second competing fill layer.
	for divider_index in range(1,10):
		var divider := ColorRect.new()
		divider.position = Vector2(447 + divider_index * 54.4 - 1,946)
		divider.size = Vector2(2,5)
		divider.color = Color("091e2a")
		divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(divider)
	energy_label = _label("5 / 10",Vector2(334,854),24,Color("e9b5ff"))
	_label("ELIXIR",Vector2(337,887),11,Color("b4a0cc"))
	notice_label = _paragraph("",Vector2(30,813),Vector2(278,103),16)
	battle_overlay = _panel(Rect2(445,290,550,294),Color("102b3e"))
	overlay_title = _label("ENTER THE ARENA",Vector2(480,317),30,Color("ffdda0"))
	overlay_text = _paragraph("Drag a card onto your half of the board.\nDestroy the rival temple to win.",Vector2(480,374),Vector2(480,120),19)
	start_button = _button("BATTLE",Vector2(580,510),Vector2(280,50),_start_or_restart)
	var battle_style := StyleBoxFlat.new()
	battle_style.bg_color = Color("b7792d")
	battle_style.border_color = Color("ffe0a0")
	battle_style.set_border_width_all(2)
	battle_style.set_corner_radius_all(12)
	start_button.add_theme_stylebox_override("normal",battle_style)

func _card_frame(border: Color, background: Color, width: int) -> StyleBoxFlat:
	var frame := StyleBoxFlat.new()
	frame.bg_color = background
	frame.border_color = border
	frame.set_border_width_all(width)
	frame.set_corner_radius_all(7)
	frame.shadow_color = Color(0,0,0,0.32)
	frame.shadow_size = 3
	frame.shadow_offset = Vector2(0,2)
	return frame

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
		if _countdown_remaining > 0.0:
			_countdown_remaining = maxf(0.0, _countdown_remaining - delta)
			var number := ceili(_countdown_remaining)
			if number != _countdown_number:
				_countdown_number = number
				hud_fx.show_countdown("BATTLE!" if number <= 0 else str(number))
				sound.play_countdown(maxi(0, number))
				if number <= 0:
					notice = "Pick a card, then deploy on your blue half."
					notice_label.text = notice
		else:
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
		var hovered: bool = button.is_hovered()
		button.position.y = lerpf(button.position.y, 798.0 if active else 808.0, 1.0-exp(-delta*18.0))
		button.scale = button.scale.lerp(Vector2.ONE * (1.055 if active else 1.025 if hovered else 1.0),1.0-exp(-delta*18.0))
	if selected_slot >= 0 and _last_pointer.x > -900: _preview(_last_pointer)
	if board and not state.is_empty(): board.show_state(state,delta)
	if board and board.ambient_life: board.ambient_life.advance(delta, paused or not started)
	if hud_fx: hud_fx.advance(delta)

func _refresh() -> void:
	state=session.snapshot()
	if sound: sound.consume_state(state)
	var seconds:=maxi(0,int(ceil(float(state.time_remaining))))
	timer_label.text="%d:%02d" % [seconds/60,seconds%60]
	match_label.text="DOUBLE ELIXIR" if float(state.elapsed)>=120 else ""
	if state.get("overtime",false): match_label.text="SUDDEN DEATH"
	var crowns:=[0,0]
	for tower in state.towers:
		if tower.hp<=0: crowns[1-int(tower.side)]+=3 if tower.kind=="temple" else 1
	score_label.text="YOU %s  :  %s RIVAL" % [crowns[0],crowns[1]]
	energy_label.text="%s / 10" % int(floor(state.energy[0]))
	energy_bar.value=state.energy[0]
	timer_label.modulate = Color("ff8a72") if seconds <= 10 and state.phase == "playing" else Color.WHITE
	get_node("NextArt").texture = _texture(state.get("next_card","hoplites"))
	next_label.text=catalog.get(state.get("next_card",""),{}).get("name","-")
	for slot in 4:
		var kind:String=state.hand[slot]
		var card:Dictionary=catalog[kind]
		cards[slot].icon.texture=_texture(kind)
		cards[slot].name.text=card.name
		cards[slot].cost.text=str(card.cost)
		cards[slot].button.tooltip_text=card.description
		var affordable: bool = state.energy[0] >= card.cost
		var selected: bool = slot == selected_slot
		# Dim only the illustration: cost and identity must stay readable while waiting.
		cards[slot].icon.modulate = Color.WHITE if affordable else Color("697783")
		cards[slot].name.modulate = Color("fff0ce") if selected else Color("e2e8e9")
		cards[slot].cost_style.bg_color = Color("653190") if affordable else Color("303342")
		cards[slot].cost_style.border_color = Color("dba7f6") if affordable else Color("9297ae")
		cards[slot].button.add_theme_stylebox_override("normal", _card_frames.selected if selected else _card_frames.normal if affordable else _card_frames.waiting)
		cards[slot].button.add_theme_stylebox_override("hover", _card_frames.selected if selected else _card_frames.hover)
		cards[slot].button.disabled=state.phase=="finished"
		cards[slot].button.add_theme_color_override("font_color", Color("fff0c6") if slot == selected_slot else Color("e7e1d2"))
	if selected_slot>=0:
		var kind:String=state.hand[selected_slot]
		selection_label.text = catalog[kind].name + (" - aim anywhere" if kind == "thunderbolt" else " - deploy on your half")
	else:
		selection_label.text = ""
	if selected_slot < 0: board.clear_preview()
	notice_label.text=notice
	if hud_fx: hud_fx.consume_state(state)
	if state.phase=="finished":
		paused=false
		selected_slot=-1
		_show_overlay(true)
		overlay_title.text="VICTORY!" if state.winner==0 else "DEFEAT" if state.winner==1 else "DRAW"
		overlay_text.text="Towers taken: %s - %s\n\n" % [crowns[0],crowns[1]]+("Your heroes have conquered the arena." if state.winner==0 else "Try a different push. Save elixir for defense." if state.winner==1 else "The temples stand. Settle it in a rematch.")
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
	_countdown_remaining=3.05
	_countdown_number=3
	selected_slot=-1
	pause_button.text="Pause"
	_show_overlay(false)
	if hud_fx:
		hud_fx.reset()
		hud_fx.show_countdown("3")
	sound.start_match()
	sound.play_countdown(3)
	notice=""
	_refresh()

func _select_card(slot:int) -> void:
	if state.phase=="finished": return
	if _countdown_remaining > 0.0:
		notice=""
		_refresh()
		return
	selected_slot=slot
	notice=""
	_refresh()

func _card_input(event:InputEvent,slot:int) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		_select_card(slot)
		if selected_slot == slot:
			_dragging=true
			drag_proxy.texture = cards[slot].icon.texture
			drag_proxy.position = event.global_position - drag_proxy.size * 0.5
			drag_proxy.visible = true

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion and _dragging:
		drag_proxy.position = event.position - drag_proxy.size * 0.5
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_1,KEY_2,KEY_3,KEY_4]: _select_card(event.keycode-KEY_1)
		elif event.keycode==KEY_ESCAPE:
			selected_slot=-1
			board.show_deployment(Vector2.INF,false)
			_refresh()
		elif event.keycode==KEY_SPACE: _toggle_pause()
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed and _dragging:
		_dragging=false
		drag_proxy.visible=false
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
		if hud_fx: hud_fx.deployed(local)
		selected_slot=-1
		board.show_deployment(Vector2.INF,false)
		sound.pitch_scale=1.2
		sound.play_move_sound()
		notice=""
	else:
		notice=str(result.get("error","You cannot deploy there."))
		if hud_fx: hud_fx.show_banner("NOT HERE", 0.65)
	_refresh()

func _toggle_pause() -> void:
	if not started or state.phase=="finished": return
	paused=not paused
	pause_button.text="Resume" if paused else "Pause"
	if paused: sound.stop_match()
	else: sound.start_match()
	notice="Paused" if paused else ""
	_refresh()

func _restart_confirm() -> void:
	var was_paused:=paused
	paused=true
	var dialog:=ConfirmationDialog.new()
	dialog.title="Start a new match?"
	dialog.dialog_text="The current match will be replaced."
	dialog.confirmed.connect(func(): session.new_game(42); started=false; paused=false; selected_slot=-1; _accumulator=0; sound.stop_match(); _show_overlay(true); overlay_title.text="ENTER THE ARENA"; overlay_text.text="New match ready. Choose your opening."; start_button.text="BATTLE"; _refresh(); dialog.queue_free())
	dialog.canceled.connect(func():
		paused=was_paused
		if not paused: sound.start_match()
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered()

func _capture(path:String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
