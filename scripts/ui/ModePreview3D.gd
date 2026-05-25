extends SubViewportContainer


@onready var sub_view = $SubViewport
@onready var world = $SubViewport/World3D
@onready var cam = $SubViewport/World3D/Camera3D

var target_factory = preload("res://scenes/characters/target.tscn")


func setup_scene(_name: String, params: Dictionary):
	var root = world
	if root == null:
		root = get_node("SubViewport/World3D")
	if not root.has_node("Walls"):
		_build_walls(root)
	for child in root.get_children():
		if child.has_method("init"):
			child.queue_free()
	var count = mini(params.get("spawn_count", 3), 5)
	for i in range(count):
		var t = target_factory.instantiate()
		var x0 = params.get("spawn_x_min", 10)
		var x1 = params.get("spawn_x_max", -10)
		var y0 = params.get("spawn_y_min", 4)
		var y1 = params.get("spawn_y_max", 10)
		var t_factor = float(i) / max(1, count - 1)
		var vis_x0 = 10
		var vis_x1 = -10
		var px = 0 if x0 == x1 else lerp(float(vis_x0), float(vis_x1), t_factor)
		var vis_y0 = 2
		var vis_y1 = 8
		var py = 0 if y0 == y1 else lerp(float(vis_y0), float(vis_y1), t_factor)
		px = clampf(px, -6.0, 6.0)
		py = clampf(py, -6.0, 6.0)
		if count > 1:
			px += (i % 2) * 2 - 1
		var sz = params.get("scale", 1.0)
		sz = max(sz, 2.0)
		var moving = params.get("allow_move", false)
		t.init(sz, i, moving)
		var existing_vel = t.get("lavelocitat")
		if existing_vel:
			t.set("lavelocitat", Vector3(existing_vel.x, existing_vel.y, 0))
		t.position = Vector3(px, py, -25.0)
		root.add_child(t)


func _build_walls(parent):
	var group = Node3D.new()
	group.name = "Walls"
	parent.add_child(group)
	var center = Vector3(0, 0, -25)
	var extent = 8.0
	var thick = 2.0
	var configs = [
		{"pos": center + Vector3(0, extent, 0), "size": Vector3(extent * 2, thick, extent * 2)},
		{"pos": center + Vector3(0, -extent, 0), "size": Vector3(extent * 2, thick, extent * 2)},
		{"pos": center + Vector3(-extent, 0, 0), "size": Vector3(thick, extent * 2, extent * 2)},
		{"pos": center + Vector3(extent, 0, 0), "size": Vector3(thick, extent * 2, extent * 2)},
		{"pos": center + Vector3(0, 0, extent), "size": Vector3(extent * 2, extent * 2, thick)},
		{"pos": center + Vector3(0, 0, -extent), "size": Vector3(extent * 2, extent * 2, thick)}
	]
	for cfg in configs:
		var body = StaticBody3D.new()
		body.position = cfg.pos
		var col = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = cfg.size
		col.shape = box
		body.add_child(col)
		group.add_child(body)
