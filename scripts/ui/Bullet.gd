extends Node3D


var destination = Vector3()
const SPEED = 1000.0
var arrived = false
var impacted = false


func _ready():
	pass


func _process(_delta):
	pass


func _physics_process(delta):
	if arrived:
		if impacted:
			queue_free()
		return
	var dir = (destination - global_transform.origin).normalized()
	var vel = dir * SPEED
	if dir.dot(destination - (global_transform.origin + vel * delta)) < 0:
		global_transform.origin = destination
		arrived = true
	else:
		translate(vel * delta)


func _on_timer_timeout():
	queue_free()
