extends CharacterBody3D


@onready var visual := $CollisionShape3D/MeshInstance3D

signal destroyed

var spawn_id = null
var movement_vector = null
var hp = 10


func _ready():
	var stored = DataManager.read("TargetColor")
	if stored != null:
		var mat = StandardMaterial3D.new()
		mat.set_albedo(Global.parse_color(stored))
		visual.material_override = mat


func init(sz = 0.5, id_val = null, moving = false):
	randomize()
	scale = Vector3(sz, sz, sz)
	if moving:
		movement_vector = Vector3(
			randf_range(-10, 10),
			randf_range(-10, 10),
			randf_range(-10, 10)
		)
	spawn_id = id_val


func _process(_delta):
	if hp <= 0:
		emit_signal("destroyed")
		queue_free()


func _physics_process(delta):
	if movement_vector:
		var collision = move_and_collide(movement_vector * delta)
		if collision:
			movement_vector = movement_vector.bounce(collision.get_normal())
