extends Control


signal refresh_crosshair


@onready var crosshair_view = $ScrollContainer/MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/Crosshair
@onready var export_dialog = $ScrollContainer/MarginContainer/HBoxContainer/VBoxContainer/ExportFileDialog
@onready var import_dialog = $ScrollContainer/MarginContainer/HBoxContainer/VBoxContainer/ImportFileDialog

var import_callback = null


func _ready():
	if OS.has_feature("web"):
		import_callback = JavaScriptBridge.create_callback(Callable(self, "_parse_import"))
		var win = JavaScriptBridge.get_interface("window")
		win.getFile(import_callback)
	export_dialog.visible = false
	import_dialog.visible = false
	_restore_saved()
	var labeled = get_tree().get_nodes_in_group("PutLabel")
	for node in labeled:
		_add_label(node)


func _add_label(target):
	var label = Label.new()
	var row = HBoxContainer.new()
	label.text = target.name + ": "
	row.add_child(label)
	var parent = target.get_parent()
	var idx = target.get_index()
	parent.remove_child(target)
	row.add_child(target)
	parent.add_child(row)
	parent.move_child(row, idx)


func _restore_saved():
	var persist = get_tree().get_nodes_in_group("Persist")
	for node in persist:
		match node.get_class():
			"CheckButton":
				if DataManager.read(node.name) != null:
					node.set_pressed(DataManager.read(node.name))
			"LineEdit":
				if DataManager.read(node.name) != null:
					node.text = str(DataManager.read(node.name))
			"ColorPickerButton":
				if DataManager.read(node.name) != null:
					node.color = Global.parse_color(DataManager.read(node.name))
			_:
				print("Unhandled persist type")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainScreen.tscn")


func _on_crosshair_toggled(state):
	DataManager.write("Crosshair", state)
	emit_signal("refresh_crosshair")


func _on_outline_toggled(state):
	DataManager.write("Outline", state)
	emit_signal("refresh_crosshair")


func _on_crosshair_inner_toggled(state):
	DataManager.write("CrosshairInner", state)
	emit_signal("refresh_crosshair")


func _on_dot_toggled(state):
	DataManager.write("Dot", state)
	emit_signal("refresh_crosshair")


func _on_dot_size_text_changed(val):
	DataManager.write("DotSize", float(val))
	emit_signal("refresh_crosshair")


func _on_outline_size_text_changed(val):
	DataManager.write("OutlineSize", float(val))
	emit_signal("refresh_crosshair")


func _on_crosshair_height_text_changed(val):
	DataManager.write("CrosshairHeight", float(val))
	emit_signal("refresh_crosshair")


func _on_crosshair_width_text_changed(val):
	DataManager.write("CrosshairWidth", float(val))
	emit_signal("refresh_crosshair")


func _on_crosshair_space_text_changed(val):
	DataManager.write("CrosshairSpace", float(val))
	emit_signal("refresh_crosshair")


func _on_crosshair_color_color_changed(color):
	DataManager.write("CrosshairColor", str(color))
	emit_signal("refresh_crosshair")


func _on_outline_color_color_changed(color):
	DataManager.write("OutlineColor", str(color))
	emit_signal("refresh_crosshair")


func _on_target_color_color_changed(color):
	DataManager.write("TargetColor", str(color))
	emit_signal("refresh_crosshair")


func _parse_import(args):
	DataManager.ingest_json(args[0])


func _on_export_pressed():
	if OS.has_feature("web"):
		DataManager.export_for_web()
	else:
		export_dialog.current_dir = "/"
		export_dialog.visible = true


func _on_import_pressed():
	if OS.has_feature("web"):
		var win = JavaScriptBridge.get_interface("window")
		win.input.click()
	else:
		import_dialog.current_dir = "/"
		import_dialog.visible = true


func _on_export_file_dialog_file_selected(path):
	DataManager.flush(path)


func _on_import_file_dialog_file_selected(path):
	DataManager.load_from_disk(path)
	DataManager.flush()
