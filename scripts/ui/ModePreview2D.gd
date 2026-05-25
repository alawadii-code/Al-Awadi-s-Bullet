extends SubViewportContainer


@onready var container = $SubViewport/Container

var target_template = preload("res://scenes/characters/Target2D.tscn")


func setup_scene(_name: String, params: Dictionary):
	var root = container
	if root == null:
		root = get_node("SubViewport/Container")
	for child in root.get_children():
		child.queue_free()
	var count = mini(params.get("spawn_count", 3), 5)
	var vp_size = Vector2(300, 300)
	var ref_size = 1000.0
	var ratio = vp_size.x / ref_size
	for i in range(count):
		var t = target_template.instantiate()
		var orig_sz = params.get("size", 40)
		var orig_margin = params.get("edge_margin", 50)
		var scaled_sz = max(orig_sz * ratio, 20.0)
		var scaled_margin = max(orig_margin * ratio, 10.0)
		var max_x = vp_size.x - scaled_margin - scaled_sz
		var max_y = vp_size.y - scaled_margin - scaled_sz
		var rx = randf_range(scaled_margin, max_x)
		var ry = randf_range(scaled_margin, max_y)
		var moving = params.get("allow_move", false)
		t.init(scaled_sz, i, moving)
		t.set_target_size(scaled_sz)
		t.position = Vector2(rx, ry)
		if t.has_node("Button"):
			t.get_node("Button").mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(t)
