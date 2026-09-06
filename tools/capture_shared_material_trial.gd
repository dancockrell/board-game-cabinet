extends SceneTree
## External-source material feasibility study. Never modifies runtime assets.
const MAP_ROOT := "C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/approved_cc0/PolyHaven/rock-boulder-dry-1k/source_files"
const DEFAULT_OUTPUT := "C:/Users/Admin/Documents/Codex/2026-09-05/referenced-chatgpt-conversation-this-is-an-2/outputs/Olympus-Reuse-Audit/shared-rock-arena-trial.png"

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var output := DEFAULT_OUTPUT
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): output = argument.trim_prefix("--capture=")
	if not output.is_absolute_path() or DisplayServer.get_name() == "headless":
		_fail("An absolute output and graphics display are required.")
		return
	var maps := {}
	var sources := []
	for role in ["diff", "arm", "nor_gl"]:
		var path := MAP_ROOT.path_join("rock_boulder_dry_%s_1k.jpg" % role)
		var image := Image.load_from_file(path)
		if image == null or image.is_empty():
			_fail("Missing approved source map: " + path)
			return
		maps[role] = ImageTexture.create_from_image(image)
		sources.append({"role": role, "path": path, "sha256": FileAccess.get_sha256(path)})
	root.size = Vector2i(1440, 960)
	root.content_scale_size = Vector2i(1440, 960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.gui_disable_input = true
	var app = preload("res://app/olympus_arena.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	app.set_process_input(false)
	app.set_process_unhandled_input(false)
	app.sound.set_muted(true)
	var stage: Node3D = app.board.get_node("OlympusStage")
	var selected: Array[MeshInstance3D] = []
	var untouched := {}
	for child in stage.get_children():
		if not child is MeshInstance3D: continue
		# Exact construction fingerprint of _sea() outcrops, plus location guard.
		# Never select limestone, paving, pillars, figures, or generic stone color.
		var shape = child.mesh
		if shape is SphereMesh and shape.radial_segments == 7 and shape.rings == 4 and child.position.y < -1.3 and absf(child.position.x) > 6.0:
			selected.append(child)
		else:
			untouched[child] = child.material_override
	if selected.size() != 18:
		_fail("Outcrop fingerprint changed: expected exactly 18, found %s. No material replaced." % selected.size())
		return
	var material := StandardMaterial3D.new()
	material.albedo_texture = maps.diff
	material.normal_enabled = true
	material.normal_texture = maps.nor_gl
	material.normal_scale = 0.7
	material.roughness_texture = maps.arm
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	material.metallic_texture = maps.arm
	material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
	material.metallic = 1.0
	material.ao_enabled = true
	material.ao_texture = maps.arm
	material.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE * 0.75
	var changed := []
	for rock in selected:
		rock.material_override = material
		changed.append({"path": str(stage.get_path_to(rock)), "position": [rock.position.x, rock.position.y, rock.position.z]})
	for mesh in untouched:
		if mesh.material_override != untouched[mesh]:
			_fail("Unexpected non-rock material change.")
			return
	var label := Label.new()
	label.text = "STAGED SHARED MATERIAL TRIAL — NOT SHIPPED"
	label.position = Vector2(40, 925)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("ffe2a5"))
	root.add_child(label)
	for frame in 24: await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	if root.get_texture().get_image().save_png(output) != OK:
		_fail("Failed saving capture.")
		return
	var report := {"status": "staged_trial_not_shipped", "source_id": "rock-boulder-dry-1k", "source_license": "CC0-1.0 per existing approved material ledger", "sources": sources, "selected_rock_count": selected.size(), "unchanged_other_stage_mesh_count": untouched.size(), "selection": "OlympusStage direct SphereMesh children with radial_segments=7, rings=4, y<-1.3, abs(x)>6; exact count18 required", "selected_nodes": changed, "mapping": "world triplanar scale0.75; OpenGL normal; ARM red AO, green roughness, blue metallic", "capture": output, "capture_sha256": FileAccess.get_sha256(output)}
	var file := FileAccess.open(output.get_basename() + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("Shared material trial: 18 rocks, %s other stage meshes unchanged. %s" % [untouched.size(), output])
	app.queue_free()
	for frame in 4: await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(2)
