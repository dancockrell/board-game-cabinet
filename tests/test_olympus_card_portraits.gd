extends SceneTree
const Battle = preload("res://app/olympus_arena.tscn")
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.size = Vector2i(1440,960)
	var app = Battle.instantiate()
	root.add_child(app)
	app.set_process(false)
	await process_frame
	app._show_overlay(false)
	var kinds = ["hoplites","atalanta","minotaur","medusa","heracles","hydra","harpies","thunderbolt"]
	for index in kinds.size():
		var kind: String = kinds[index]
		var panel := ColorRect.new()
		panel.position = Vector2(100+index*155,400)
		panel.size = Vector2(145,150)
		panel.color = Color("122630")
		app.add_child(panel)
		var portrait := TextureRect.new()
		portrait.position = Vector2(15,8)
		portrait.size = Vector2(114,100)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		panel.add_child(portrait)
		app._set_portrait(portrait,kind)
		var caption := Label.new()
		caption.text = kind.capitalize()
		caption.position = Vector2(8,118)
		panel.add_child(caption)
		if kind != "thunderbolt":
			if portrait.texture.atlas != app.PORTRAITS[kind].atlas or portrait.material == null:
				failures += 1
		else:
			if portrait.material != null: failures += 1
		# Switching a recycled card back to spell artwork clears the chroma material.
		var probe := TextureRect.new()
		app._set_portrait(probe,kind)
		app._set_portrait(probe,"thunderbolt")
		if probe.material != null: failures += 1
		probe.free()
	await process_frame
	await RenderingServer.frame_post_draw
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			if root.get_texture().get_image().save_png(argument.trim_prefix("--capture=")) != OK: failures += 1
	print("Card portraits: 16 checks, %d failures" % failures)
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
