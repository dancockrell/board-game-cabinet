extends SceneTree
## Native review of the shared material now used by the stage.
const MAP_ROOT := "res://assets/olympus_arena/materials/rock-boulder-dry-1k"
const DEFAULT_OUTPUT := "C:/Users/Admin/Documents/Codex/2026-09-05/referenced-chatgpt-conversation-this-is-an-2/outputs/Olympus-Reuse-Audit/shared-rock-arena-trial.png"

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var output := DEFAULT_OUTPUT
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--review-output="): output = argument.trim_prefix("--review-output=")
	if not output.is_absolute_path() or DisplayServer.get_name() == "headless":
		_fail("An absolute output and graphics display are required.")
		return
	var sources := []
	for role in ["diff", "arm", "nor_gl"]:
		var path := MAP_ROOT.path_join("rock_boulder_dry_%s_1k.jpg" % role)
		if not FileAccess.file_exists(path):
			_fail("Missing bundled map: " + path)
			return
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
	app._show_overlay(false)
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
	var material = preload("res://themes/olympus_shared_rock.tres")
	var changed := []
	for rock in selected:
		if rock.material_override != material:
			_fail("Stage did not use the canonical rock material.")
			return
		changed.append({"path": str(stage.get_path_to(rock)), "position": [rock.position.x, rock.position.y, rock.position.z]})
	for mesh in untouched:
		if mesh.material_override != untouched[mesh]:
			_fail("Unexpected non-rock material change.")
			return
	var label := Label.new()
	label.text = "SHARED ROCK MATERIAL / RUNTIME REVIEW"
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
	var report := {"status": "runtime_material_review", "source_id": "rock-boulder-dry-1k", "source_license": "CC0-1.0 per existing approved material ledger", "sources": sources, "selected_rock_count": selected.size(), "unchanged_other_stage_mesh_count": untouched.size(), "selection": "OlympusStage direct SphereMesh children with radial_segments=7, rings=4, y<-1.3, abs(x)>6; exact count18 required", "selected_nodes": changed, "mapping": "Canonical themes/olympus_shared_rock.tres: world triplanar scale0.75; OpenGL normal; ARM red AO, green roughness, blue metallic", "capture": output, "capture_sha256": FileAccess.get_sha256(output)}
	var file := FileAccess.open(output.get_basename() + ".json", FileAccess.WRITE)
	report["albedo_multiplier"] = [0.45, 0.45, 0.45, 1.0]
	report["intro_overlay_hidden"] = true
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("Shared material trial: 18 rocks, %s other stage meshes unchanged. %s" % [untouched.size(), output])
	app.queue_free()
	for frame in 4: await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(2)
