extends Node3D
## Latar menu utama Tiny Haven - suasana malam.
##
## Palet warna diambil dari ikon game: malam ungu tua, rumput toska,
## lavender, dan aksen merah muda.
##
## Tugas skrip ini:
##   1. menyebar hutan di sekeliling kemah secara prosedural,
##   2. menyiapkan langit malam, kabut ungu, dan cahaya bulan,
##   3. menyalakan api unggun sebagai sumber cahaya hangat,
##   4. memutar kamera perlahan mengelilingi kemah.
##
## Pasang pada node Node3D paling atas di scenes/ui/main_menu.tscn.

const FirefliesScript := preload("res://scripts/fireflies.gd")

const NATURE_DIR := "res://assets/model/nature/"
const TREES: Array[String] = [
	"tree_oak.glb",
	"tree_tall.glb",
	"tree_default.glb",
	"tree_pineTallA.glb",
	"tree_small.glb",
]
const ROCKS: Array[String] = [
	"rock_largeA.glb",
	"rock_smallA.glb",
	"stump_round.glb",
]
const GROUND_COVER: Array[String] = [
	"flower_redA.glb",
	"mushroom_redGroup.glb",
]

# Palet dari assets/icon/icon-game.png
const NIGHT_DEEP := Color("0b0b2f")
const NIGHT_SOFT := Color("110d3a")
const PURPLE := Color("892bd8")
const LAVENDER := Color("c9a8ff")
const FIRE_WARM := Color("ff8a3d")

## Seed tetap supaya susunan hutan selalu sama setiap dijalankan.
@export var random_seed: int = 2026
@export var tree_count: int = 90
@export var rock_count: int = 25
@export var cover_count: int = 60
## Jari-jari tanah lapang di sekitar kemah; tidak ada pohon di dalamnya.
@export var clearing_radius: float = 6.5
@export var forest_radius: float = 17.0

## Posisi api unggun, disamakan dengan campfire_logs di scene.
@export var campfire_position := Vector3(1.5, 0.35, 0.5)

@export var camera_distance: float = 24.0
@export var camera_height: float = 9.5
@export var camera_speed: float = 0.04
@export var camera_fov: float = 42.0

var _rng := RandomNumberGenerator.new()
var _camera: Camera3D
var _campfire_light: OmniLight3D
var _angle: float = 0.9
var _flicker: float = 0.0

func _ready() -> void:
	_rng.seed = random_seed
	_build_environment()
	_build_forest()
	_build_campfire_light()
	_build_camera()
	add_child(FirefliesScript.new())

func _process(delta: float) -> void:
	_angle += camera_speed * delta
	_place_camera()
	_flicker += delta * 7.0
	# Nyala api dibuat bergoyang halus memakai dua gelombang sinus.
	_campfire_light.light_energy = 3.0 + sin(_flicker) * 0.35 + sin(_flicker * 2.3) * 0.2

## Langit malam berbintang, kabut ungu, dan cahaya bulan kebiruan.
func _build_environment() -> void:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = NIGHT_DEEP
	sky_material.sky_horizon_color = PURPLE
	sky_material.ground_bottom_color = NIGHT_DEEP
	sky_material.ground_horizon_color = NIGHT_SOFT
	sky_material.sky_energy_multiplier = 0.9

	var sky := Sky.new()
	sky.sky_material = sky_material

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_bloom = 0.25
	env.fog_enabled = true
	env.fog_light_color = Color("3a2060")
	env.fog_density = 0.02
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.2
	env.adjustment_contrast = 1.08

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-38.0, -130.0, 0.0)
	moon.light_color = LAVENDER
	moon.light_energy = 0.55
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 80.0
	add_child(moon)

func _build_forest() -> void:
	_scatter(TREES, tree_count, 0.75, 1.5)
	_scatter(ROCKS, rock_count, 0.6, 1.3)
	_scatter(GROUND_COVER, cover_count, 0.7, 1.2)

## Sebar model dalam bentuk cincin: acak sudut, jarak, putaran, dan ukuran.
func _scatter(files: Array[String], count: int, scale_min: float, scale_max: float) -> void:
	var span := forest_radius - clearing_radius
	for i in count:
		var packed := load(NATURE_DIR + files[_rng.randi() % files.size()]) as PackedScene
		if packed == null:
			continue
		var item := packed.instantiate() as Node3D
		if item == null:
			continue
		var angle := _rng.randf() * TAU
		# Akar kuadrat membuat sebarannya rata, tidak menumpuk di tepi dalam.
		var radius := clearing_radius + sqrt(_rng.randf()) * span
		item.position = Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		item.rotation.y = _rng.randf() * TAU
		item.scale = Vector3.ONE * _rng.randf_range(scale_min, scale_max)
		add_child(item)

func _build_campfire_light() -> void:
	_campfire_light = OmniLight3D.new()
	_campfire_light.position = campfire_position
	_campfire_light.light_color = FIRE_WARM
	_campfire_light.light_energy = 3.0
	_campfire_light.omni_range = 11.0
	_campfire_light.shadow_enabled = true
	add_child(_campfire_light)

func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = camera_fov
	_camera.current = true
	add_child(_camera)
	_place_camera()

func _place_camera() -> void:
	var focus := Vector3(0.0, 1.2, 0.0)
	var offset := Vector3(cos(_angle) * camera_distance, camera_height, sin(_angle) * camera_distance)
	_camera.position = focus + offset
	_camera.look_at(focus, Vector3.UP)
