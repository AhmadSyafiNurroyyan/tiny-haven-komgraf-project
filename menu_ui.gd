extends CanvasLayer
## Tampilan menu utama Tiny Haven.
##
## Tata letaknya mengikuti gaya Stormy Knights: papan judul di atas tengah,
## lalu deretan tombol pelat selebar papan di bawahnya.
##
## Font (keduanya di assets/fonts/):
##   judul      - Magic Light, dibiarkan halus karena hurufnya berlekuk
##   sisanya    - Minecraft, penghalusan tepi dimatikan supaya pikselnya tajam
##                dan ukurannya dipilih kelipatan 8 agar tidak pecah
## Kalau file fontnya belum ada, skrip memakai font bawaan Godot
## supaya tampilan tetap jalan.
##
## Pasang pada node CanvasLayer di scenes/ui/main_menu.tscn.

const TITLE := "TINY HAVEN"
const SUBTITLE := "A COZY MINIATURE WORLD BUILDER"
const ITEMS: Array[String] = [
	"Mulai",
	"Lanjutkan",
	"Pengaturan",
	"Kredit",
	"Keluar",
]
const VERSION_TEXT := "Iterasi 3 - Prototipe"

# Palet dari assets/icon/icon-game.png
const NIGHT := Color("110d3a")
const PLATE := Color("2a1f4d")
const PLATE_HOVER := Color("3d2d6b")
const PINK := Color("ff3fa8")
const LAVENDER := Color("c9a8ff")
const CREAM := Color("fff3c4")
const TEAL := Color("1fb89a")

const FONTS_DIR := "res://assets/fonts/"
## Nama file diperiksa berurutan; yang pertama ketemu yang dipakai.
const TITLE_FONT_FILES: Array[String] = [
	"Magiclightdemo-BWzXB.ttf",
	"MagicLight.ttf",
]
const UI_FONT_FILES: Array[String] = [
	"Minecraft.ttf",
	"minecraft.ttf",
]

var _title_font: Font
var _ui_font: Font

func _ready() -> void:
	layer = 1
	_title_font = _find_font(TITLE_FONT_FILES, false)
	_ui_font = _find_font(UI_FONT_FILES, true)
	_add_vignette()
	_add_menu()
	_add_version()

## Cari file font pertama yang benar-benar ada di assets/fonts/.
## Kalau pixel_perfect true, penghalusan tepinya dimatikan supaya tetap tajam.
func _find_font(candidates: Array[String], pixel_perfect: bool) -> Font:
	for name in candidates:
		var path := FONTS_DIR + name
		if not ResourceLoader.exists(path):
			continue
		var font := load(path) as Font
		var file := font as FontFile
		if pixel_perfect and file != null:
			file.antialiasing = TextServer.FONT_ANTIALIASING_NONE
			file.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
			file.hinting = TextServer.HINTING_NONE
		return font
	return null

## Pasang font antarmuka (Minecraft) pada sebuah Label atau Button.
func _apply_font(target: Control, size: int) -> void:
	if _ui_font != null:
		target.add_theme_font_override("font", _ui_font)
	target.add_theme_font_size_override("font_size", size)

## Gelap di tepi atas dan bawah supaya teks tetap terbaca di atas scene 3D.
func _add_vignette() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	gradient.colors = PackedColorArray([
		Color(NIGHT.r, NIGHT.g, NIGHT.b, 0.72),
		Color(NIGHT.r, NIGHT.g, NIGHT.b, 0.08),
		Color(NIGHT.r, NIGHT.g, NIGHT.b, 0.62),
	])

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)

	var vignette := TextureRect.new()
	vignette.texture = texture
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vignette)

func _add_menu() -> void:
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 54)
	margin.add_theme_constant_override("margin_bottom", 54)
	add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_BEGIN
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	column.add_child(_title_banner())
	column.add_child(_spacer(46))
	for item in ITEMS:
		column.add_child(_menu_button(item))

## Papan judul: pelat gelap bergaris merah muda, judul dan subjudul di dalamnya.
func _title_banner() -> Control:
	var wrapper := CenterContainer.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _banner_style())
	wrapper.add_child(panel)

	var inner := VBoxContainer.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_theme_constant_override("separation", 2)
	panel.add_child(inner)

	var title := Label.new()
	title.text = TITLE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _title_font != null:
		title.add_theme_font_override("font", _title_font)
	title.add_theme_font_size_override("font_size", 84)
	title.add_theme_color_override("font_color", CREAM)
	title.add_theme_color_override("font_outline_color", Color("1a0f33"))
	title.add_theme_constant_override("outline_size", 12)
	inner.add_child(title)

	var subtitle := Label.new()
	subtitle.text = SUBTITLE
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_font(subtitle, 16)
	subtitle.add_theme_color_override("font_color", TEAL)
	subtitle.add_theme_constant_override("outline_size", 0)
	inner.add_child(subtitle)

	return wrapper

func _banner_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PLATE.r, PLATE.g, PLATE.b, 0.92)
	style.border_color = PINK
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	style.content_margin_left = 54.0
	style.content_margin_right = 54.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 18.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0.0, 5.0)
	return style

func _spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, float(height))
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer

## Tombol pelat lebar bergaya Stormy Knights.
func _menu_button(text: String) -> Control:
	var wrapper := CenterContainer.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_PASS

	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(430.0, 56.0)
	_apply_font(button, 24)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", LAVENDER)
	button.add_theme_stylebox_override("normal", _plate_style(PLATE, PINK))
	button.add_theme_stylebox_override("hover", _plate_style(PLATE_HOVER, LAVENDER))
	button.add_theme_stylebox_override("pressed", _plate_style(PLATE.darkened(0.2), PINK))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if text == "Keluar":
		button.pressed.connect(_on_quit_pressed)
	wrapper.add_child(button)

	return wrapper

func _plate_style(fill: Color, accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill.r, fill.g, fill.b, 0.9)
	style.border_color = accent
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0.0, 3.0)
	return style

func _add_version() -> void:
	var label := Label.new()
	label.text = VERSION_TEXT
	_apply_font(label, 16)
	label.add_theme_color_override("font_color", Color(LAVENDER.r, LAVENDER.g, LAVENDER.b, 0.8))
	label.anchor_left = 0.0
	label.anchor_right = 0.0
	label.anchor_top = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 26.0
	label.offset_right = 420.0
	label.offset_top = -44.0
	label.offset_bottom = -20.0
	add_child(label)

func _on_quit_pressed() -> void:
	get_tree().quit()
