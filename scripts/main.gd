extends Node3D
# Kontrol: Klik kiri = tambah titik tembok | Klik kanan = selesai | Z = undo
#          Klik tengah + geser = putar kamera | Scroll = zoom | Panah = geser kamera

const CameraRigScript = preload("res://scripts/camera_rig.gd")
const WallBuilderScript = preload("res://scripts/wall_builder.gd")
const SheepScript = preload("res://scripts/sheep.gd")
const FirefliesScript = preload("res://scripts/fireflies.gd")

var cam_rig
var walls

func _ready() -> void:
	_setup_environment()
	_setup_ground()
	cam_rig = CameraRigScript.new()
	add_child(cam_rig)
	walls = WallBuilderScript.new()
	add_child(walls)
	for i in 5:
		var s = SheepScript.new()
		s.position = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		add_child(s)
	add_child(FirefliesScript.new())

func _setup_environment() -> void:
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.shadow_enabled = true
	add_child(sun)

func _setup_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(80, 80)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.36, 0.62, 0.30)
	mat.roughness = 1.0
	plane.material = mat
	ground.mesh = plane
	add_child(ground)

func _ground_point(screen_pos: Vector2) -> Variant:
	var cam: Camera3D = cam_rig.cam
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	return Plane(Vector3.UP, 0.0).intersects_ray(from, dir)

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_LEFT:
			var p: Variant = _ground_point(e.position)
			if p != null:
				walls.add_point(p)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			walls.commit()
	elif e is InputEventKey and e.pressed and e.keycode == KEY_Z:
		walls.undo()