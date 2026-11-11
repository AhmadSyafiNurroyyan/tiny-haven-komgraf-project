extends CPUParticles3D
class_name Fireflies

func _ready() -> void:
	amount = 60
	lifetime = 6.0
	preprocess = 6.0
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emission_box_extents = Vector3(15, 1.5, 15)
	gravity = Vector3.ZERO
	direction = Vector3.UP
	spread = 180.0
	initial_velocity_min = 0.1
	initial_velocity_max = 0.4
	position.y = 1.5
	var m := SphereMesh.new()
	m.radius = 0.04
	m.height = 0.08
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.9, 0.4)
	m.material = mat
	mesh = m
