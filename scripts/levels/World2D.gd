extends Control


var target_blueprint = preload("res://scenes/characters/Target2D.tscn")
var points = 0
var time_left = 0
var round_active = false


@onready var arena = $TargetContainer
@onready var score_display = $HUD/Score
@onready var timer_display = $HUD/Timer
@onready var hud_layer = $HUD
@onready var pause_screen = $CanvasLayer/Pause


func _ready():
	points = 0
	var config = Global.mode_2d[Global.active_mode]
	time_left = config["round_time"]
	round_active = true
	score_display.text = "Score: 0"
	timer_display.text = str(time_left) + "s"
	for _i in range(config["spawn_count"]):
		_place_target()
	$GameTimer.start()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _toggle_pause():
	var state = !get_tree().paused
	get_tree().paused = state
	pause_screen.visible = state


func _process(delta):
	pass


func _place_target():
	if !round_active:
		return
	var config = Global.mode_2d[Global.active_mode]
	var margin = config["edge_margin"]
	var sz = config["size"]
	var vp = get_viewport_rect().size
	var max_x = vp.x - margin - sz
	var max_y = vp.y - margin - sz
	var rx = randf_range(margin, max_x)
	var ry = randf_range(margin, max_y)
	var t = target_blueprint.instantiate()
	var moving = config.get("allow_move", false)
	t.init(sz, 0, moving)
	t.set_target_size(sz)
	t.position = Vector2(rx, ry)
	t.connect("destroyed", Callable(self, "_on_target_hit"))
	arena.add_child(t)


func _on_target_hit():
	if !round_active:
		return
	points += 1
	score_display.text = "Score: " + str(points)
	_place_target()


func _on_game_timer_timeout():
	time_left -= 1
	timer_display.text = str(time_left) + "s"
	if time_left <= 0:
		_end_round()


func _end_round():
	round_active = false
	$GameTimer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	timer_display.text = "Finished!"


func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainScreen.tscn")


func _on_resume_pressed():
	_toggle_pause()
