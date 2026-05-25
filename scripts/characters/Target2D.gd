extends TextureButton


signal destroyed

var idx = 0
var speed_vec = Vector2.ZERO
var boundary: Rect2


func init(size_px, _idx, moving = false):
	idx = _idx
	if moving:
		var speed = 200.0
		speed_vec = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
		set_process(true)
	else:
		set_process(false)


func _ready():
	connect("pressed", Callable(self, "_on_click"))
	var p = get_parent()
	if p is Control:
		boundary = p.get_rect()
	elif p is SubViewport:
		boundary = p.get_visible_rect()


func _process(delta):
	if speed_vec != Vector2.ZERO:
		position += speed_vec * delta
		var area = Rect2()
		var p = get_parent()
		if p is Control:
			area.size = p.size
			area.position = Vector2.ZERO
		elif p is SubViewportContainer:
			area.size = p.size
		else:
			area = get_viewport_rect()
		if position.x <= 0:
			speed_vec.x = abs(speed_vec.x)
		elif position.x + size.x >= area.size.x:
			speed_vec.x = -abs(speed_vec.x)
		if position.y <= 0:
			speed_vec.y = abs(speed_vec.y)
		elif position.y + size.y >= area.size.y:
			speed_vec.y = -abs(speed_vec.y)


func set_target_size(px):
	custom_minimum_size = Vector2(px, px)
	size = Vector2(px, px)
	if texture_normal == null:
		var rect = ColorRect.new()
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect.color = Color.WHITE
		add_child(rect)


func _on_click():
	emit_signal("destroyed")
	queue_free()
