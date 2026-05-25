extends Node3D


var target_scene = preload("res://scenes/characters/target.tscn")
var spawn_pos = Vector3()
var total_kills = 0
var next_id = 0

const FULLSCREEN_FLAG = 3


@onready var kill_anim = $Player/Head/AnimationKill
@onready var kill_label = $Player/Head/Kill
@onready var score_label = $Player/Head/Kills
@onready var result_label = $CanvasLayer/Pause/Buttons/Kills
@onready var fullscreen_overlay = $CanvasLayer/FullScreenRequest
@onready var mouse_overlay = $CanvasLayer/MouseCapturedRequested


func _ready():
	fullscreen_overlay.visible = false
	mouse_overlay.visible = false
	_request_fullscreen()
	next_id = 0
	total_kills = 0
	result_label.set_text(tr("KILLS_ON") % [str(total_kills), tr(str(Global.active_mode))])
	kill_label.visible = false
	for _i in range(Global.mode_3d[Global.active_mode].spawn_count):
		_spawn()


func _process(_delta):
	await get_tree().create_timer(0.5).timeout
	_request_fullscreen()


func _on_target_destroyed():
	_show_hit_feedback()
	_spawn()


func _random_pos():
	randomize()
	var cfg = Global.mode_3d[Global.active_mode]
	var px = randf_range(cfg.spawn_x_min, cfg.spawn_x_max)
	var py = randf_range(cfg.spawn_y_min, cfg.spawn_y_max)
	return Vector3(px, py, -25)


func _validate_distance():
	var candidate = _random_pos()
	var dist = 0
	var ok = true
	return [ok, candidate, dist]


func _spawn():
	next_id += 1
	var check = _validate_distance()
	var attempts = 0
	while check[0] != true and attempts < 100:
		attempts += 1
		check = _validate_distance()
	var pt = check[1]
	spawn_pos.x = pt.x
	spawn_pos.y = pt.y
	spawn_pos.z = pt.z
	var t = target_scene.instantiate()
	t.init(Global.mode_3d[Global.active_mode].scale, next_id, Global.mode_3d[Global.active_mode].allow_move)
	t.connect("destroyed", Callable(self, "_on_target_destroyed"))
	t.set_position(spawn_pos)
	add_child(t)


func _show_hit_feedback():
	total_kills += 1
	score_label.set_text(str(total_kills))
	result_label.set_text(tr("KILLS_ON") % [str(total_kills), tr(str(Global.active_mode))])
	if not kill_anim.is_playing():
		kill_anim.play("kill")


func _on_menu_pressed():
	pass


func _request_fullscreen():
	if DisplayServer.window_get_mode() < FULLSCREEN_FLAG or Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		if fullscreen_overlay.visible == false and get_tree().paused == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			fullscreen_overlay.visible = true
			get_tree().paused = true


func _on_full_screen_needed_pressed():
	fullscreen_overlay.visible = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_overlay.visible = true


func _on_mouse_captured_needed_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_overlay.visible = false
	get_tree().paused = false
