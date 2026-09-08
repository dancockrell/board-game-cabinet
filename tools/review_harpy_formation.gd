extends SceneTree
## Controlled legal deployment, with fixed opening hand and enemy AI/fire disabled.
func _initialize(): run.call_deferred()
func run():
	var output:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--formation-output="): output=arg.trim_prefix("--formation-output=")
	if not output.is_absolute_path(): quit(2);return
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
	app.session.bot_enabled=false
	app.session._hands[0][0]="harpies"
	for tower in app.session._state.towers: tower.cooldown=1000.0
	if not app.session.deploy(0,Vector2(2.7,5.0)).ok: quit(3);return
	app._refresh()
	var smallest:=100.0
	for frame in 180:
		app._process(1.0/30.0)
		if app.state.units.size()==2:
			var a=app.state.units[0]
			var b=app.state.units[1]
			smallest=minf(smallest,Vector2(a.x,a.z).distance_to(Vector2(b.x,b.z)))
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%frame))
	var report={"frames":180,"fps":30,"minimum_authoritative_pair_gap":smallest,"authoritative_snapshot_matches":app.state==app.session.snapshot(),"scope":"Controlled legal Harpy deployment; fixed hand; rival AI and shrine shots disabled. Six seconds at normal presentation speed."}
	FileAccess.open(output.path_join("study.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("Harpy formation native study minimum gap: ",smallest)
	quit(0 if report.authoritative_snapshot_matches else 1)
