extends Control


signal pause_game
signal resume_game

const FULLSCREEN = 3


func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		_set_pause(true)


func _set_pause(state: bool):
	get_tree().paused = state
	visible = state
	if state:
		$Buttons/Resume.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("pause_game")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		emit_signal("resume_game")


func _on_resume_pressed():
	_set_pause(false)


func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainScreen.tscn")


func _on_player_pause_game():
	_set_pause(true)
