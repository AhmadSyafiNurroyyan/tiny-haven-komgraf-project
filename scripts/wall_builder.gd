extends Node3D
class_name WallBuilder
# Tembok prosedural: tiap segmen disusun dari batu acak (MultiMesh).
# Segmen yang cukup panjang otomatis dapat lubang pintu di tengah.
# Batu di baris atas sebagian berwarna hijau (efek ivy).

const ROW_H := 0.22
const ROWS := 6
const THICK := 0.35
const DOOR_W := 1.0
const DOOR_ROWS := 4

var points: Array[Vector3] = []
var _mmi: MultiMeshInstance3D
var _rng := RandomNumberGenerator.new()

func add_point(p: Vector3) -> void:
	points.append(p)
	_rebuild()

func undo() -> void:
	if points.size() > 0:
		points.pop_back()
		_rebuild()

func commit() -> void:
	# Selesaikan tembok saat ini, mulai tembok baru.
	points.clear()
	_mmi = null

func _rebuild() -> void:
	if _mmi:
		_mmi.queue_free()
		_mmi = null
	if points.size() < 2:
		return
	_rng.seed = 12345  # seed tetap supaya batu tidak "berubah" tiap rebuild
	var xforms: Array[Transform3D] = []
	var colors: Array[Color] = []
	for i in points.size() - 1:
		_wall_segment(points[i], points[i + 1], xforms, colors)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	var box := BoxMesh.new()
	box.material = mat
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = box
	mm.instance_count = xforms.size()
	for i in xforms.size():
		mm.set_instance_transform(i, xforms[i])
		mm.set_instance_color(i, colors[i])
	_mmi = MultiMeshInstance3D.new()
	_mmi.multimesh = mm
	add_child(_mmi)

func _wall_segment(a: Vector3, b: Vector3, xf: Array[Transform3D], col: Array[Color]) -> void:
	var dir := b - a
	var seg_len := dir.length()
	if seg_len < 0.1:
		return
	dir /= seg_len
	var angle := atan2(-dir.z, dir.x)
	var door_mid := seg_len * 0.5 if seg_len > 4.0 else -1.0
	for row in ROWS:
		var t := _rng.randf_range(0.0, 0.15) if row % 2 == 0 else _rng.randf_range(0.2, 0.35)
		while t < seg_len:
			var w := _rng.randf_range(0.3, 0.5)
			w = minf(w, seg_len - t)
			var c := t + w * 0.5
			t += w + 0.01
			if door_mid > 0.0 and row < DOOR_ROWS and absf(c - door_mid) < DOOR_W * 0.5:
				continue
			var size := Vector3(w, ROW_H * _rng.randf_range(0.9, 1.0), THICK * _rng.randf_range(0.85, 1.0))
			var bs := Basis(Vector3.UP, angle + _rng.randf_range(-0.05, 0.05)) * Basis.from_scale(size)
			var pos := a + dir * c + Vector3(0, ROW_H * (row + 0.5), 0)
			xf.append(Transform3D(bs, pos))
			if row >= ROWS - 2 and _rng.randf() < 0.4:
				col.append(Color(0.35, 0.5, 0.25))  # ivy
			else:
				col.append(Color.from_hsv(0.08, 0.1, _rng.randf_range(0.55, 0.75)))
