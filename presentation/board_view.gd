extends Node3D
class_name BoardView
## Presentation only. Every piece comes from the authoritative 64-square snapshot.
signal square_clicked(square: int)

const WOOD = preload("res://presentation/wood.gdshader")
const BRAND = preload("res://presentation/brand.gdshader")
const SYMBOLS = {
    "p": preload("res://assets/symbols/p.svg"),
    "r": preload("res://assets/symbols/r.svg"),
    "n": preload("res://assets/symbols/n.svg"),
    "b": preload("res://assets/symbols/b.svg"),
    "q": preload("res://assets/symbols/q.svg"),
    "k": preload("res://assets/symbols/k.svg"),
}
@export var board_theme: Resource = preload("res://themes/wooden_board.tres")
@export var piece_theme: Resource = preload("res://themes/wooden_pieces.tres")
var _pieces: Node3D
var _markers: Node3D
var _camera: Camera3D
var _flipped: bool = false
var _zoom: float = 11.8
var _snapshot: Array = []

func _ready() -> void:
    _build_stage()
    _build_board()
    _pieces = Node3D.new()
    add_child(_pieces)
    _markers = Node3D.new()
    add_child(_markers)
    if not _snapshot.is_empty():
        show_position(_snapshot)

func _wood(color: Color, seed: float = 0.0) -> ShaderMaterial:
    var mat := ShaderMaterial.new()
    mat.shader = WOOD
    mat.set_shader_parameter("wood_color", color)
    mat.set_shader_parameter("grain_seed", seed)
    return mat

func _plain(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.65
    mat.metallic = metallic
    return mat

func _mesh(parent: Node3D, shape: Mesh, position_: Vector3, material: Material) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = shape
    instance.position = position_
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _box(parent: Node3D, size: Vector3, position_: Vector3, material: Material) -> MeshInstance3D:
    var shape := BoxMesh.new()
    shape.size = size
    return _mesh(parent, shape, position_, material)

func _disk(parent: Node3D, radius: float, height: float, y: float, material: Material, top_radius: float = -1.0) -> void:
    var shape := CylinderMesh.new()
    shape.bottom_radius = radius
    shape.top_radius = radius if top_radius < 0.0 else top_radius
    shape.height = height
    shape.radial_segments = 64
    _mesh(parent, shape, Vector3(0.0, y, 0.0), material)

func _build_stage() -> void:
    var environment := WorldEnvironment.new()
    environment.environment = Environment.new()
    environment.environment.background_mode = Environment.BG_COLOR
    environment.environment.background_color = Color("192421")
    environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.environment.ambient_light_color = Color("dbe5e0")
    environment.environment.ambient_light_energy = 0.48
    environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    add_child(environment)
    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-57.0, -28.0, 0.0)
    key.light_color = Color("ffe6bd")
    key.light_energy = 1.15
    key.shadow_enabled = true
    key.directional_shadow_max_distance = 35.0
    key.shadow_bias = 0.04
    add_child(key)
    var fill := OmniLight3D.new()
    fill.position = Vector3(3.5, 5.0, -4.0)
    fill.light_color = Color("cbdce7")
    fill.light_energy = 1.0
    fill.omni_range = 15.0
    add_child(fill)
    _box(self, Vector3(200.0, 0.2, 200.0), Vector3(0.0, -0.52, 0.0), _plain(Color("20302b")))
    _camera = Camera3D.new()
    _camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    _camera.keep_aspect = Camera3D.KEEP_WIDTH
    _camera.current = true
    _camera.far = 100.0
    add_child(_camera)
    _update_camera()

func _build_board() -> void:
    var s: float = board_theme.square_size
    var outer: float = 8.0 * s + 2.0 * board_theme.frame_width
    _box(self, Vector3(outer - 0.10, 0.10, outer - 0.10), Vector3(0.0, -0.30, 0.0), _wood(board_theme.frame_color.darkened(0.3)))
    _box(self, Vector3(outer, 0.26, outer), Vector3(0.0, -0.14, 0.0), _wood(board_theme.frame_color, 1.5))
    # Slim maple inlay around the playing field gives a clean crafted edge.
    _box(self, Vector3(8.08 * s, 0.028, 8.08 * s), Vector3(0.0, 0.002, 0.0), _wood(Color("c8a773")))
    for sq in range(64):
        var dark: bool = (sq % 8 + sq / 8) % 2 == 0
        var color: Color = board_theme.dark_square if dark else board_theme.light_square
        var point := square_position(sq)
        point.y = 0.025
        _box(self, Vector3(s * 0.999, 0.044, s * 0.999), point, _wood(color, float(sq) * 0.371))
    for i in range(8):
        var offset: float = (float(i) - 3.5) * s
        _coordinate(String.chr(97 + i), Vector3(offset, 0.026, 4.26 * s))
        _coordinate(str(i + 1), Vector3(-4.26 * s, 0.026, (3.5 - i) * s))
        _coordinate(String.chr(97 + i), Vector3(offset, 0.026, -4.26 * s), true)
        _coordinate(str(i + 1), Vector3(4.26 * s, 0.026, (3.5 - i) * s), true)

func _coordinate(text_: String, at: Vector3, reverse: bool = false) -> void:
    var label := Label3D.new()
    label.text = text_
    label.font_size = 56
    label.pixel_size = 0.0035
    label.modulate = board_theme.coordinate_color
    label.outline_size = 0
    label.no_depth_test = false
    label.position = at
    label.rotation_degrees.x = -90.0
    if reverse:
        label.rotation_degrees.z = 180.0
    add_child(label)

func square_position(square: int) -> Vector3:
    return Vector3(float(square % 8) - 3.5, 0.05, 3.5 - float(square / 8)) * board_theme.square_size

func show_position(board: Array) -> void:
    _snapshot = board.duplicate()
    if not is_instance_valid(_pieces):
        return
    for child in _pieces.get_children():
        _pieces.remove_child(child)
        child.queue_free()
    for square in range(mini(board.size(), 64)):
        var piece: String = str(board[square])
        if piece.is_empty() or not SYMBOLS.has(piece.to_lower()):
            continue
        _make_piece(square, piece)

func _make_piece(square: int, piece: String) -> void:
    var white: bool = piece == piece.to_upper()
    var node := Node3D.new()
    node.position = square_position(square)
    _pieces.add_child(node)
    var color: Color = piece_theme.white_color if white else piece_theme.black_color
    var radius: float = piece_theme.radius * board_theme.square_size
    var height: float = piece_theme.height * board_theme.square_size
    var body := _wood(color, float(square) * 0.827)
    _disk(node, radius * 0.94, height * 0.15, height * 0.075, _wood(color.darkened(0.26)), radius)
    _disk(node, radius, height * 0.62, height * 0.46, body)
    _disk(node, radius, height * 0.23, height * 0.885, body, radius * 0.91)
    # A shallow inset face sits below a raised wood lip.
    _disk(node, radius * 0.83, 0.008, height - 0.001, _wood(color.lightened(0.07), float(square) * 0.827))
    var brand := ShaderMaterial.new()
    brand.shader = BRAND
    brand.set_shader_parameter("symbol_texture", SYMBOLS[piece.to_lower()])
    brand.set_shader_parameter("char_color", piece_theme.white_brand if white else piece_theme.black_brand)
    var plane := PlaneMesh.new()
    plane.size = Vector2.ONE * piece_theme.symbol_scale * board_theme.square_size
    var icon := _mesh(node, plane, Vector3(0.0, height + 0.004, 0.0), brand)
    icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    # Brands face the player on either side of the table.
    if not white:
        icon.rotation.y = PI

func show_highlights(selected: int, legal_targets: Array, last_from: int = -1, last_to: int = -1, checked_square: int = -1) -> void:
    if not is_instance_valid(_markers):
        return
    for child in _markers.get_children():
        _markers.remove_child(child)
        child.queue_free()
    for square in [last_from, last_to]:
        if square >= 0:
            _outline(square, Color("8f9b78"), 0.026)
    if selected >= 0:
        _outline(selected, board_theme.selected_color, 0.045)
    for target in legal_targets:
        var occupied: bool = int(target) < _snapshot.size() and not str(_snapshot[int(target)]).is_empty()
        if occupied:
            _outline(int(target), board_theme.legal_color, 0.048)
        else:
            var marker := Node3D.new()
            marker.position = square_position(int(target)) + Vector3(0.0, 0.004, 0.0)
            _markers.add_child(marker)
            _disk(marker, 0.103, 0.012, 0.0, _plain(board_theme.legal_color))
    if checked_square >= 0:
        _outline(checked_square, Color("e99178"), 0.055)

func _outline(square: int, color: Color, width: float) -> void:
    var center := square_position(square) + Vector3(0.0, 0.008, 0.0)
    var s: float = board_theme.square_size * 0.91
    var mat := _plain(color)
    for sign_ in [-1.0, 1.0]:
        _box(_markers, Vector3(s, 0.013, width), center + Vector3(0.0, 0.0, sign_ * s / 2.0), mat)
        _box(_markers, Vector3(width, 0.013, s), center + Vector3(sign_ * s / 2.0, 0.0, 0.0), mat)

func set_flipped(value: bool) -> void:
    _flipped = value
    if is_instance_valid(_camera):
        _update_camera()

func zoom_by(amount: float) -> void:
    _zoom = clampf(_zoom + amount, 10.0, 15.5)
    _update_camera()

func _update_camera() -> void:
    _camera.size = _zoom
    _camera.position = Vector3(0.0, 11.8, -8.4 if _flipped else 8.4)
    _camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)

func screen_to_square(point: Vector2) -> int:
    if not is_instance_valid(_camera):
        return -1
    var origin := _camera.project_ray_origin(point)
    var direction := _camera.project_ray_normal(point)
    var hit: Variant = Plane(Vector3.UP, 0.05).intersects_ray(origin, direction)
    if hit == null:
        return -1
    var p: Vector3 = to_local(hit)
    var file_: int = int(floor(p.x / board_theme.square_size + 4.0))
    var rank_: int = int(floor(4.0 - p.z / board_theme.square_size))
    return rank_ * 8 + file_ if file_ >= 0 and file_ < 8 and rank_ >= 0 and rank_ < 8 else -1

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            var square := screen_to_square(event.position)
            if square >= 0:
                square_clicked.emit(square)
                get_viewport().set_input_as_handled()
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom_by(-0.35)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom_by(0.35)
