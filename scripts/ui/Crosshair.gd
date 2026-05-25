extends Control


var tint = Color(0, 255, 255, 1)
var border_tint = Color(0, 0, 0)

var show_cross = true
var show_border = true
var show_inner = true
var show_dot = false

var dot_radius = 6
var border_thick = 2
var arm_height = 4
var arm_width = 12
var arm_gap = 5

var dot_verts = []
var left_arm = []
var top_arm = []
var right_arm = []
var bottom_arm = []


func _load_state():
	if DataManager.read("Crosshair") != null:
		show_cross = DataManager.read("Crosshair")
	if DataManager.read("Outline") != null:
		show_border = DataManager.read("Outline")
	if DataManager.read("CrosshairInner") != null:
		show_inner = DataManager.read("CrosshairInner")
	if DataManager.read("Dot") != null:
		show_dot = DataManager.read("Dot")
	if DataManager.read("DotSize") != null:
		dot_radius = DataManager.read("DotSize")
	if DataManager.read("OutlineSize") != null:
		border_thick = DataManager.read("OutlineSize")
	if DataManager.read("CrosshairHeight") != null:
		arm_height = DataManager.read("CrosshairHeight")
	if DataManager.read("CrosshairWidth") != null:
		arm_width = DataManager.read("CrosshairWidth")
	if DataManager.read("CrosshairSpace") != null:
		arm_gap = DataManager.read("CrosshairSpace")
	if DataManager.read("CrosshairColor") != null:
		tint = Global.parse_color(DataManager.read("CrosshairColor"))
	if DataManager.read("OutlineColor") != null:
		border_tint = Global.parse_color(DataManager.read("OutlineColor"))
	dot_verts = [
		Vector2(-dot_radius, -dot_radius),
		Vector2(dot_radius, -dot_radius),
		Vector2(dot_radius, dot_radius),
		Vector2(-dot_radius, dot_radius)
	]
	left_arm = [
		Vector2(-arm_width - arm_gap, -arm_height),
		Vector2(-arm_gap, -arm_height),
		Vector2(-arm_gap, arm_height),
		Vector2(-arm_width - arm_gap, arm_height)
	]
	top_arm = [
		Vector2(-arm_height, -arm_width - arm_gap),
		Vector2(arm_height, -arm_width - arm_gap),
		Vector2(arm_height, -arm_gap),
		Vector2(-arm_height, -arm_gap)
	]
	right_arm = [
		Vector2(arm_gap, -arm_height),
		Vector2(arm_width + arm_gap, -arm_height),
		Vector2(arm_width + arm_gap, arm_height),
		Vector2(arm_gap, arm_height)
	]
	bottom_arm = [
		Vector2(-arm_height, arm_gap),
		Vector2(arm_height, arm_gap),
		Vector2(arm_height, arm_gap + arm_width),
		Vector2(-arm_height, arm_gap + arm_width)
	]


func redraw(_value):
	queue_redraw()


func _draw():
	_load_state()
	if show_dot and show_cross:
		_fill_poly(dot_verts, tint, border_thick, border_tint)
	if show_inner and show_cross:
		_fill_poly(left_arm, tint, border_thick, border_tint)
		_fill_poly(top_arm, tint, border_thick, border_tint)
		_fill_poly(right_arm, tint, border_thick, border_tint)
		_fill_poly(bottom_arm, tint, border_thick, border_tint)


func _fill_poly(pts, color, border_w, border_color):
	var arr = PackedVector2Array()
	arr = pts
	var cols = PackedColorArray([color])
	draw_polygon(arr, cols)
	var proxy = Polygon2D.new()
	proxy.set_polygon(arr)
	_draw_border(proxy, border_w, border_color)


func _draw_border(proxy, thickness, color):
	if show_border:
		var poly = proxy.get_polygon()
		for i in range(1, poly.size()):
			draw_line(poly[i - 1], poly[i], color, thickness)
		draw_line(poly[poly.size() - 1], poly[0], color, thickness)


func _on_options_refresh_crosshair():
	queue_redraw()
