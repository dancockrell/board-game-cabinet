extends SceneTree
const Board=preload("res://presentation/olympus_arena_board.gd")
const Clip=preload("res://themes/olympus_shrine_collapse_clip.tres")
var failures:=0
var checks:=0
func check(ok:bool, label:String):
	checks+=1
	if not ok: failures+=1; push_error(label)
func _initialize(): run.call_deferred()
func run():
	check(Clip.validation_error().is_empty(),"Authored collapse Resource validates")
	var board=Board.new()
	root.add_child(board)
	var state={"units":[],"towers":[{"id":"shrine","kind":"tower","side":0,"x":0.0,"z":2.0,"hp":100.0,"max_hp":100.0}],"events":[],"elapsed":1.0}
	board.show_state(state,0.0)
	var tower=board._towers.shrine
	var building=tower.get_node("Architecture/PixelBuilding")
	state.towers[0].hp=0.0
	board.show_state(state,0.0)
	check(board._collapses.size()==1,"One destruction starts one authored collapse")
	var fx=board._collapses[0].fx
	check(fx._ghost.clip==Clip and fx._ghost._shown==0,"Destruction enters first cracked drawing")
	check(building.clip==Board.RUBBLE_CLIP and not building.visible,"Authoritative destroyed shrine prepared as rubble without double drawing")
	var seen:={}
	for frame in 82:
		if not board._collapses.is_empty():
			seen[fx._ghost._shown]=true
			check(fx._ghost.scale.x==fx._ghost.scale.y,"Rigid drawing keeps aspect ratio; no squash animation")
			var age=fx.age
			board.show_state(state,0.0)
			check(fx.age==age and board._collapses.size()==1,"Paused repeated snapshot holds exact collapse")
		board.show_state(state,1.0/60.0)
	check(seen.size()==9,"All eight new stages and existing final rubble drawing reached")
	check(board._collapses.is_empty() and building.visible,"Animation hands over to permanent rubble")
	check(building.clip==Board.RUBBLE_CLIP and tower.position==Vector3(0,.1,2),"Ruins retain authoritative footprint")
	state.elapsed=0.0
	state.towers[0].hp=100.0
	board.show_state(state,0.0)
	check(building.visible and building.clip==Board.SHRINE_CLIP and board._collapses.is_empty(),"Reset restores intact shrine without stale collapse")
	board.free()
	print("Authored shrine collapse: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
