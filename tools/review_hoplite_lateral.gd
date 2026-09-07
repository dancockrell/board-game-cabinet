extends SceneTree
const West = preload("res://themes/hoplite_west_walk.tres")
const East = preload("res://themes/hoplite_east_walk.tres")
func _initialize(): _run.call_deferred()
func _run():
 root.size=Vector2i(1440,960)
 var board=preload("res://presentation/olympus_arena_board.gd").new()
 root.add_child(board)
 board.camera.size=6
 board.camera.position=Vector3(0,10.5,14)
 board.camera.look_at(Vector3(0,.6,3))
 var actors=[]
 for i in 2:
  var actor=preload("res://presentation/pixel_actor.gd").new()
  board.add_child(actor)
  actor.pixel_size=.0027
  actor.position=Vector3(-1.3+2.6*i,.15,3)
  var clip=West if i==0 else East
  assert(clip.validation_error().is_empty())
  assert(actor.reset_playback(clip))
  assert(actor.set_locomotion(clip))
  actors.append(actor)
 var folder=ProjectSettings.globalize_path("res://../../outputs/Hoplite-Lateral-Walk-frames")
 DirAccess.make_dir_recursive_absolute(folder)
 for frame in 60:
  for actor in actors: actor.advance_visual(1.0/30)
  for tick in 2: await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("frame-%04d.png"%frame))
 print("Lateral review: 60 native frames, 2 clips")
 quit()
