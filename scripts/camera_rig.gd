extends Node3D
class_name CameraRig

var yaw := 0.6
var pitch := -0.9
var dist := 12.0
var cam: Camera3D

func _ready() -> void:
	cam = Camera3D.new()
	add_child(cam)
	_apply()

func _apply() -> void:
	rotation = Vector3(pitch, yaw, 0.0)
	cam.position = Vector3(0, 0, dist)

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		yaw -= e.relative.x * 0.005
		pitch = clampf(pitch - e.relative.y * 0.005, -1.4, -0.2)
		_apply()
	elif e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			dist = maxf(3.0, dist - 1.0)
			_apply()
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			dist = minf(40.0, dist + 1.0)
			_apply()

func _process(delta: float) -> void:
	var v := Vector3(Input.get_axis("ui_left", "ui_right"), 0, Input.get_axis("ui_up", "ui_down"))
	if v != Vector3.ZERO:
		position += v.rotated(Vector3.UP, yaw) * 8.0 * delta
