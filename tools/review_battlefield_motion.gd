extends SceneTree
## Six seconds of the real controller at 30 presentation frames per second.
## Warmup and legal automated deployment are explicit; no hand-posed combat state.
var placements:=0
func _initialize(): run.call_deferred()
func deploy_available(app):
	for slot in 4:
		var point=Vector2(-2.7 if placements%2==0 else 2.7,1.3)
		if app.state.hand[slot]=="thunderbolt": point.y=-3.0
		if app.session.deploy(slot,point).get("ok",false):
			placements+=1
			app._refresh()
			return
func run():
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--motion-output="): output=arg.trim_prefix("--motion-output=")
	if not output.is_absolute_path(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	var app=preload("res://app/olympus_arena.gd").new()
	app.preferences_path=""
	root.add_child(app)
	app.set_process(false)
	app.sound.set_muted(true)
	app.session.new_game(42)
	app._refresh()
	app._start_or_restart()
	app._countdown_remaining=0.0
	# Advance to established battle through the same controller and legal requests.
	for tick in 300:
		if tick%10==0: deploy_available(app)
		app._process(.1)
	var beginning=float(app.state.elapsed)
	for frame in 180:
		if frame%30==0: deploy_available(app)
		app._process(1.0/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	var report={"start_seconds":beginning,"end_seconds":app.state.elapsed,"frames":180,"fps":30,"legal_deployments_including_warmup":placements,"authoritative_snapshot_matches":app.state==app.session.snapshot(),"scope":"Six-second native controller sample after 30-second legal-match warmup; not full-match validation"}
	FileAccess.open(output.path_join("study.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("Native battlefield motion: 180 frames at 30 fps; authoritative state match: ",report.authoritative_snapshot_matches)
	quit(0 if report.authoritative_snapshot_matches else 1)
