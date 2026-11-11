extends Node3D
class_name Sheep

var target := Vector3.ZERO
var speed := 0.6
var area := 12.0
var wait := 0.0
var _body: MeshInstance3D

func _ready() -> void:
	_body = _part(_sphere(0.3), Color(0.95, 0.95, 0.92), Vector3(0, 0.35, 0))
	_body.scale = Vector3(1, 0.85, 1.3)
	_part(_sphere(0.14), Color(0.2, 0.18, 0.18), Vector3(0, 0.5, 0.42))  # kepala (+Z = depan)
	target = position

func _sphere(r: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	return s

func _part(mesh: Mesh, color: Color, pos: Vector3) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	m.mesh = mesh
	m.position = pos
	add_child(m)
	return m

func _process(delta: float) -> void:
	if wait > 0.0:
		wait -= delta
		return
	var d := target - position
	d.y = 0.0
	if d.length() < 0.1:
		wait = randf_range(1.0, 4.0)
		target = Vector3(randf_range(-area, area), 0, randf_range(-area, area))
		return
	position += d.normalized() * speed * delta
	rotation.y = lerp_angle(rotation.y, atan2(d.x, d.z), delta * 4.0)
	_body.position.y = 0.35 + absf(sin(Time.get_ticks_msec() * 0.01)) * 0.03
