extends Control
## Real-time controller. Fixed simulation ticks own every placement and hit.
const Session = preload("res://games/olympus_arena/session.gd")
const Arena = preload("res://presentation/olympus_arena_board.gd")
const MoveAudio = preload("res://presentation/move_audio.gd")
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
	theme_.default_font_size=18
	theme_.set_color("font_color","Label",Color("f5e9cd"))
	for name_ in ["normal","hover","pressed","focus","disabled"]:
		var style:=StyleBoxFlat.new()
		style.bg_color=Color("30475a") if name_=="hover" else Color("1c3042")
		style.border_color=Color("eed08f") if name_=="focus" else Color("526575")
		style.set_border_width_all(2)
		style.set_corner_radius_all(9)
		theme_.set_stylebox(name_,"Button",style)
	theme=theme_
	var bg:=ColorRect.new()
	bg.color=Color("0c1927")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_label("OLYMPUS ARENA",Vector2(30,22),32,Color("f4d999"))
	_label("GREEK HEROES. MONSTROUS BATTLES.",Vector2(32,62),13,Color("93b3c6"))
	timer_label=_label("3:00",Vector2(658,20),34,Color("fff4d6"))
	match_label=_label("PRACTICE MATCH",Vector2(604,63),14,Color("92b4c7"))
	_button("Chess cabinet",Vector2(1210,24),Vector2(200,42),func(): get_tree().change_scene_to_file("res://app/main.tscn"))
	_panel(Rect2(22,110,270,656),Color("132a3c"))
	_label("YOUR CARD",Vector2(42,130),15,Color("94b7d0"))
	card_preview=TextureRect.new()
	card_preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	card_preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card_preview.position=Vector2(69,175)
	card_preview.size=Vector2(170,145)
	card_preview.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(card_preview)
	selection_label=_label("Pick your opening",Vector2(42,336),23,Color("f3d79b"))
	selection_label.size=Vector2(230,64)
	selection_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	description_label=_paragraph("Select one of the four cards below the arena. Deploy troops on your side; they will cross a bridge and fight automatically.",Vector2(42,410),Vector2(226,158),18)
	_label("HOW TO WIN",Vector2(42,588),15,Color("94b7d0"))
	_paragraph("Destroy the enemy temple to win immediately. Otherwise, take more towers before time runs out.",Vector2(42,622),Vector2(226,112),17)
	surface=SubViewportContainer.new()
	surface.position=Vector2(306,99)
	surface.size=Vector2(828,675)
	surface.stretch=true
	surface.mouse_filter=Control.MOUSE_FILTER_STOP
	surface.gui_input.connect(_arena_input)
	add_child(surface)
	viewport=SubViewport.new()
	viewport.size=Vector2i(828,675)
	viewport.own_world_3d=true
	viewport.msaa_3d=Viewport.MSAA_4X
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	surface.add_child(viewport)
	board=Arena.new()
	viewport.add_child(board)
	_panel(Rect2(1148,110,270,656),Color("132a3c"))
	_label("TOWERS TAKEN",Vector2(1168,133),15,Color("94b7d0"))
	score_label=_label("YOU 0  :  0 RIVAL",Vector2(1168,174),23,Color("f4d999"))
	_label("BLUE: YOUR ARMY\nRED: YOUR RIVAL",Vector2(1168,224),17,Color("cddfea"))
	_label("NEXT IN YOUR HAND",Vector2(1168,304),15,Color("94b7d0"))
	next_label=_label("",Vector2(1168,345),22,Color("f3d79b"))
	next_label.size=Vector2(228,64)
	next_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	_paragraph("Elixir refills over time. Save for a powerful monster, or defend with cheaper troops.\n\nThe final minute gives double elixir.",Vector2(1168,427),Vector2(228,160),17)
	pause_button=_button("Pause",Vector2(1168,613),Vector2(108,42),_toggle_pause)
	_button("Restart",Vector2(1290,613),Vector2(108,42),_restart_confirm)
	var mute:=CheckButton.new()
	mute.text="Sound"
	mute.button_pressed=true
	mute.position=Vector2(1162,685)
	mute.toggled.connect(func(on): muted=not on; sound.set_muted(muted))
	add_child(mute)
	for slot in 4:
		var button:=Button.new()
		button.position=Vector2(356+slot*185,797)
		button.size=Vector2(176,115)
		button.gui_input.connect(func(event): _card_input(event,slot))
		button.pressed.connect(func(): _select_card(slot))
		add_child(button)
		var icon:=TextureRect.new()
		icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position=Vector2(48,7)
		icon.size=Vector2(81,71)
		icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		var name_label:=Label.new()
		name_label.position=Vector2(3,80)
		name_label.size=Vector2(170,28)
		name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size",17)
		name_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		button.add_child(name_label)
		var cost_label:=Label.new()
		cost_label.position=Vector2(12,9)
		cost_label.add_theme_font_size_override("font_size",25)
		cost_label.add_theme_color_override("font_color",Color("dea9ff"))
		cost_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		button.add_child(cost_label)
		var key_label:=Label.new()
		key_label.text=str(slot+1)
		key_label.position=Vector2(152,9)
		key_label.add_theme_font_size_override("font_size",14)
		key_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		button.add_child(key_label)
		cards.append({"button":button,"icon":icon,"name":name_label,"cost":cost_label})
	energy_bar=ProgressBar.new()
	energy_bar.position=Vector2(356,924)
	energy_bar.size=Vector2(734,17)
	energy_bar.max_value=10
	energy_bar.show_percentage=false
	var fill:=StyleBoxFlat.new()
	fill.bg_color=Color("b178ec")
	fill.set_corner_radius_all(6)
	energy_bar.add_theme_stylebox_override("fill",fill)
	add_child(energy_bar)
	energy_label=_label("5 / 10",Vector2(249,913),23,Color("d3a9ff"))
	_label("ELIXIR",Vector2(173,920),15,Color("b19dc7"))
	notice_label=_label("",Vector2(30,794),17,Color("f1cc8c"))
	notice_label.size=Vector2(282,110)
	notice_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	battle_overlay=_panel(Rect2(460,285,520,286),Color("102236"))
	overlay_title=_label("ENTER THE ARENA",Vector2(493,310),29,Color("f4d999"))
	overlay_text=_paragraph("Four cards. Two lanes. One temple to break.\n\nChoose a card and deploy on the blue half.\nYour troops take it from there.",Vector2(493,365),Vector2(450,120),19)
	start_button=_button("BATTLE",Vector2(590,501),Vector2(260,48),_start_or_restart)

func _panel(rect:Rect2,color:Color) -> Panel:
	var panel:=Panel.new()
	panel.position=rect.position
	panel.size=rect.size
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.border_color=Color("345065")
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
	if board and not state.is_empty(): board.show_state(state,delta)

func _refresh() -> void:
	state=session.snapshot()
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
	next_label.text=catalog.get(state.get("next_card",""),{}).get("name","—")
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
		selection_label.text=catalog[kind].name+" · "+str(catalog[kind].cost)
		description_label.text=catalog[kind].description
		card_preview.texture=_texture(kind)
	else:
		selection_label.text="Choose your next card" if started else "Pick your opening"
		description_label.text="Select a card below, then click your half of the arena. Your troops will move and fight automatically."
		card_preview.texture=null
	notice_label.text=notice
	if state.phase=="finished":
		paused=false
		selected_slot=-1
		_show_overlay(true)
		overlay_title.text="VICTORY!" if state.winner==0 else "DEFEAT" if state.winner==1 else "DRAW"
		overlay_text.text="Towers taken: %s — %s\n\n" % [crowns[0],crowns[1]]+("Your heroes have conquered the arena." if state.winner==0 else "Try a different push. Save elixir for defense." if state.winner==1 else "The temples stand. Settle it in a rematch.")
		start_button.text="REMATCH"
	board.show_state(state,0.0)

func _texture(kind:String) -> Texture2D:
	if not _textures.has(kind):
		var path:="res://assets/olympus_arena/"+kind+".svg"
		_textures[kind]=load(path) if ResourceLoader.exists(path) else null
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
	board.show_deployment(point,valid,state.hand[selected_slot]=="thunderbolt")

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
