extends Control


@onready var mode_selector = $MenuPanel/Controls/GameBox/Game
@onready var res_display = $MenuPanel/Controls/QualityRow/ResolutionLabel
@onready var game_list = $MenuPanel/ScrollContainer/GameList
@onready var quality_slider = $MenuPanel/Controls/QualityRow/QualitySlider
@onready var sens_field = $MenuPanel/Controls/GameBox/Sensitivity
@onready var quit_btn = $MenuPanel/Controls/Quit
@onready var toggle_3d = $Header/TopRow/CheckButton
@onready var sens_row = $MenuPanel/Controls/GameBox
@onready var options_btn = $MenuPanel/Controls/Options


const Preview3D = preload("res://scenes/ui/ModePreview3D.tscn")
const Preview2D = preload("res://scenes/ui/ModePreview2D.tscn")


func _ready():
	toggle_3d.toggled.connect(_on_mode_toggle)
	if OS.has_feature("web"):
		quality_slider.visible = false
		res_display.visible = false
		quit_btn.visible = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	populate_game_list()
	if DataManager.read("resolution"):
		quality_slider.value = DataManager.read("resolution")
	if DataManager.read("sensitivity"):
		sens_field.text = str(DataManager.read("sensitivity"))
	if DataManager.read("sensitivity_game"):
		mode_selector.selected = DataManager.read("sensitivity_game")
	populate_sensitivity_options()
	var stored_3d = DataManager.read("is_3d_mode")
	if stored_3d != null:
		toggle_3d.button_pressed = stored_3d
	refresh_ui(toggle_3d.button_pressed)
	get_viewport().size_changed.connect(_refresh_res_label)
	_refresh_res_label()


func populate_sensitivity_options():
	for entry in Global.sensitivity_presets:
		mode_selector.add_item(entry)


func populate_game_list():
	for child in game_list.get_children():
		child.queue_free()
	for key in Global.mode_3d:
		var card = _build_card(key, Global.mode_3d[key], true)
		game_list.add_child(card)


func _build_card(mode_id: String, data: Dictionary, is_3d: bool):
	var card = HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 180)
	card.size_flags_horizontal = 3

	var preview_wrap = Control.new()
	preview_wrap.custom_minimum_size = Vector2(240, 160)

	var preview
	if is_3d:
		preview = Preview3D.instantiate()
	else:
		preview = Preview2D.instantiate()
	preview.setup_scene(mode_id, data)
	preview_wrap.add_child(preview)

	var info = VBoxContainer.new()
	info.size_flags_horizontal = 3
	info.size_flags_vertical = 4

	var name_label = Label.new()
	name_label.text = mode_id
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.uppercase = true

	var desc = Label.new()
	var desc_text = "Static targets"
	if data.get("allow_move", false):
		desc_text = "Moving targets"
	desc.text = desc_text
	desc.add_theme_color_override("font_color", Color(0.5, 0.5, 0.7, 1))
	desc.add_theme_font_size_override("font_size", 14)

	var spacer = Control.new()
	spacer.size_flags_vertical = 3

	var play_btn = Button.new()
	play_btn.text = "▶  PLAY"
	play_btn.name = mode_id
	play_btn.custom_minimum_size = Vector2(160, 40)
	play_btn.add_theme_color_override("font_color", Color(1, 0.42, 0.42, 1))
	play_btn.add_theme_color_override("font_hover_color", Color(1, 0.7, 0.7, 1))
	play_btn.add_theme_font_size_override("font_size", 18)

	if is_3d:
		play_btn.pressed.connect(_launch.bind(mode_id))
	else:
		play_btn.pressed.connect(_launch_2d.bind(mode_id))

	info.add_child(name_label)
	info.add_child(desc)
	info.add_child(spacer)
	info.add_child(play_btn)

	card.add_child(preview_wrap)
	card.add_child(info)
	return card


func _launch(mode_id: String):
	if !OS.has_feature("web"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.active_mode = mode_id
	get_tree().change_scene_to_file("res://scenes/levels/World.tscn")


func _refresh_res_label():
	var render_size = get_viewport().size * get_viewport().scaling_3d_scale
	res_display.text = "%d x %d (%d%%)" % [
		render_size.x, render_size.y,
		round(get_viewport().scaling_3d_scale * 100)
	]


func _on_play_pressed():
	if toggle_3d.button_pressed:
		var keys = []
		for key in Global.mode_3d.keys():
			keys.push_back(key)
		var pick = keys[randi() % keys.size()]
		_launch(pick)
	else:
		var keys = []
		for key in Global.mode_2d.keys():
			keys.push_back(key)
		var pick = keys[randi() % keys.size()]
		_launch_2d(pick)


func _on_quality_slider_value_changed(value: float):
	get_viewport().scaling_3d_scale = value
	_refresh_res_label()
	DataManager.write("resolution", value)


func _on_quit_pressed():
	get_tree().quit()


func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Options.tscn")


func _on_sensitivity_text_changed(new_text):
	DataManager.write("sensitivity_game", mode_selector.get_selected_id())
	DataManager.write("sensitivity_game_value",
		Global.sensitivity_presets.get(mode_selector.get_item_text(mode_selector.get_selected_id())))
	DataManager.write("sensitivity", float(new_text))


func _on_game_item_selected(index):
	DataManager.write("sensitivity_game", index)
	DataManager.write("sensitivity_game_value",
		Global.sensitivity_presets.get(mode_selector.get_item_text(index)))
	get_tree().change_scene_to_file("res://scenes/ui/Options.tscn")


func _on_mode_toggle(is_3d: bool):
	DataManager.write("is_3d_mode", is_3d)
	refresh_ui(is_3d)
	toggle_3d.text = "3D" if is_3d else "2D"
	if is_3d:
		Global.active_mode = ""
		populate_game_list()
	else:
		Global.active_mode = ""
		populate_2d_list()


func populate_2d_list():
	for child in game_list.get_children():
		child.queue_free()
	for key in Global.mode_2d:
		var card = _build_card(key, Global.mode_2d[key], false)
		game_list.add_child(card)


func _launch_2d(mode_id: String):
	Global.active_mode = mode_id
	get_tree().change_scene_to_file("res://scenes/levels/World2D.tscn")


func refresh_ui(is_3d: bool):
	if sens_row:
		sens_row.visible = is_3d
	if options_btn:
		options_btn.visible = is_3d
	if !OS.has_feature("web"):
		quality_slider.visible = is_3d
		res_display.visible = is_3d
