extends SceneTree
const Collapse = preload("res://presentation/olympus_collapse_fx.gd")
var failures := 0
var checks := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var building := Sprite3D.new()
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	building.texture = ImageTexture.create_from_image(image)
	building.position = Vector3(0, .05, .4)
	building.pixel_size = .0014
	var effect := Collapse.new()
	root.add_child(effect)
	effect.begin(building)
	check(effect._particles.size() == 34, "Dust and stones created once")
	effect.begin(building)
	check(effect._particles.size() == 34, "Duplicate begin does not duplicate effect")
	effect.advance_visual(.2)
	check(effect._ghost.visible and effect._ghost.scale.y < 1.0, "Shrine visibly falls before disappearing")
	var particle_position: Vector3 = effect._particles[0].node.position
	effect.advance_visual(0)
	check(effect._particles[0].node.position == particle_position, "Pause freezes debris")
	check(building.position == Vector3(0, .05, .4) and building.scale == Vector3.ONE, "Source shrine untouched")
	effect.advance_visual(.4)
	check(not effect._ghost.visible and effect.visible, "Dust survives after shrine drops")
	effect.advance_visual(4.0)
	check(effect.is_finished() and not effect.visible, "Effect has bounded lifetime")
	for particle in effect._particles:
		check(particle.node is Sprite3D, "Collapse debris is flat pixel artwork")
		check(particle.node.position.is_finite() and particle.node.position.y >= 0, "Debris stays above ground")
	building.free()
	effect.free()
	print("Collapse checks: ", checks, "; failures: ", failures)
	quit(1 if failures else 0)
