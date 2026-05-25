extends CharacterBody3D


signal pause_game

const WALK_SPEED = 20.0
const JUMP_POWER = 25
const ACCEL = 50.0
const DECEL = 5.0

var game_sens = 0.0707589285714285
var user_sens = 0.14
var mouse_sens = 0.00990624999999999

var spread_on = true
var attack_damage = 10
var shot_count = 0
var remaining = 60
var move_dir = Vector3()

@onready var neck = $Head
@onready var eye = $Head/Camera3D
@onready var scanner = $Head/Camera3D/RayCast3D
@onready var countdown = $"../Timer"
@onready var hud_timer = $Head/Timer
@onready var bullet_scene = preload("res://scenes/levels/Bullet.tscn")
@onready var pause_ui = $"../CanvasLayer/Pause"
@onready var kill_counter = $"../CanvasLayer/Pause/Buttons/Kills"
@onready var resume_btn = $"../CanvasLayer/Pause/Buttons/Resume"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fire_callback = Callable(self, "_shoot")
var worker = Thread.new()
var live_bullets = []


func _ready():
	pause_ui.visible = false
	kill_counter.visible = false
	resume_btn.visible = true
	hud_timer.set_text(str(remaining) + "s")
	if DataManager.read("sensitivity_game_value"):
		game_sens = DataManager.read("sensitivity_game_value")
	if DataManager.read("sensitivity"):
		user_sens = DataManager.read("sensitivity")
	if OS.has_feature("web"):
		mouse_sens = user_sens * game_sens * 0.67857142857142857143
	else:
		mouse_sens = user_sens * game_sens
	worker.start(fire_callback)
	var stop = Callable(self, "_stop_worker")
	var start = Callable(self, "_start_worker")
	pause_ui.connect("pause_game", stop)
	pause_ui.connect("resume_game", start)


func _exit_tree():
	if worker.is_alive():
		worker.wait_to_finish()
	for b in live_bullets:
		if b != null:
			b.queue_free()
	live_bullets.clear()


func _shoot():
	while not get_tree().paused:
		call_deferred("fire")
		OS.delay_msec(50)


func _start_worker():
	if not worker.is_alive():
		worker.start(fire_callback)


func _stop_worker():
	if worker.is_alive():
		worker.wait_to_finish()


func _place_bullet(instance):
	if eye.is_inside_tree():
		instance.global_transform.origin = eye.global_transform.origin + Vector3(1, -1, 0)


func fire():
	if Input.is_action_just_pressed("fire"):
		if scanner.is_colliding():
			var hit = scanner.get_collider()
			var bullet = bullet_scene.instantiate()
			get_tree().root.call_deferred("add_child", bullet)
			call_deferred("_place_bullet", bullet)
			bullet.destination = scanner.get_collision_point()
			if hit != null:
				if hit.is_in_group("Enemy"):
					hit.hp -= attack_damage
					bullet.impacted = true
			live_bullets.append(bullet)
		shot_count += 1
		if countdown.is_stopped():
			countdown.start()


func _input(event):
	if event is InputEventMouseMotion:
		neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		eye.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		eye.rotation.x = clamp(eye.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	else:
		if event.is_action_pressed("ui_cancel"):
			emit_signal("pause_game")


func _physics_process(delta):
	fire()
	if not is_on_floor():
		velocity.y -= (gravity * 6) * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_POWER
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var dir = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dir:
		if dir.dot(velocity.normalized()) < 0:
			velocity = Vector3.ZERO
		else:
			velocity += dir * ACCEL * delta
			if velocity.length() > WALK_SPEED:
				velocity = velocity.normalized() * WALK_SPEED
	else:
		velocity -= velocity * DECEL * delta
	if spread_on:
		scanner.rotation = Vector3(deg_to_rad(90), 0, 0)
		scanner.rotate_x(_calc_spread())
		scanner.rotate_y(_calc_spread())
		scanner.rotate_z(_calc_spread())
	move_and_slide()


func _calc_spread() -> float:
	var base = 2
	var speed_penalty = 0
	if velocity.length() > (WALK_SPEED * 0.3):
		speed_penalty = velocity.length()
	randomize()
	return deg_to_rad(randf_range(-base, base) * speed_penalty)


func _on_timer_timeout():
	remaining -= 1
	hud_timer.set_text(str(remaining) + "s")
	if int(remaining) <= 0:
		kill_counter.visible = true
		resume_btn.visible = false
		emit_signal("pause_game")
