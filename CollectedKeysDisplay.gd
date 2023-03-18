extends ReferenceRect

export (PackedScene) var key_icon = preload("res://Menu's/KeyIcon.tscn")

export (Vector2) var key_offset = Vector2.ZERO

export var render_vertical = false
export var instant_render = false
export var collected_keys = 0
export var total_keys = 3
export var appear_speed = 0.5
export var appear_delay = 0.5

var icons = []
var keys = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_node_or_null("AppearDelay") == null:
		var timer = Timer.new()
		timer.name = "AppearDelay"
		add_child(timer)
	$AppearDelay.wait_time = appear_delay
	if instant_render:
		render_instant()

func setup(new_keys):
	keys = new_keys
	total_keys = len(keys)

func reset():
	icons.clear()

func render(new_keys = keys):
	if len(new_keys) == 0:
		return
	reset()
	keys = new_keys
	total_keys = len(keys)
	
	var rect = get_global_rect()
	
	var size = rect.size
	var pos_offset = Vector2.ZERO
	
	var target_width = size.x / total_keys - key_offset.x * total_keys
	for i in range(total_keys):
		var new_icon = key_icon.instance()
		var icon_size = new_icon.texture.get_size() * new_icon.scale
		new_icon.scale = Vector2(target_width / icon_size.x, size.y / icon_size.y)
		new_icon.position = pos_offset
		add_child(new_icon)
		icons.append(new_icon)
		pos_offset.x += icon_size.x * new_icon.scale.x + key_offset.x
	$AppearDelay.start()

func render_instant(new_keys = null, is_vertical = render_vertical):
	keys = new_keys
	if keys == null:
		keys = []
		for i in range(total_keys):
			if i < collected_keys:
				keys.append(true)
			else:
				keys.append(false)
	else:
		if len(keys) == 0:
			return
		total_keys = len(keys)
	reset()
	
	var rect = get_global_rect()
	
	var size = rect.size
	var pos_offset = Vector2.ZERO

	var target_size = (size.x / total_keys - key_offset.x * total_keys) if not is_vertical \
		else  (size.y / total_keys - key_offset.y * total_keys)
	for i in range(total_keys):
		var new_icon = key_icon.instance()
		var icon_size = new_icon.texture.get_size() * new_icon.scale
		new_icon.scale = Vector2(target_size / icon_size.x, size.y / icon_size.y) if not is_vertical \
			else Vector2(size.x / icon_size.x, target_size / icon_size.y)
		new_icon.position = pos_offset
		add_child(new_icon)
		if keys[i]:
			new_icon.self_modulate = Color.white
		icons.append(new_icon)
		if is_vertical:
			pos_offset.y += icon_size.y * new_icon.scale.y + key_offset.y
		else:
			pos_offset.x += icon_size.x * new_icon.scale.x + key_offset.x

func animate_new_keys(new_keys):
	if total_keys == 0:
		return
	
	for i in range(total_keys):
		if i >= len(new_keys):
			break
		if new_keys[i] == true and keys[i] == false:
			icons[i].get_node("AnimationPlayer").play("Appear")

func _on_AppearDelay_timeout():
	for i in range(len(keys)):
		if keys[i]:
#			AnimationHelper.reconfige_animation_lenght(icons[i].get_node("AnimationPlayer").get_animation("Appear"), appear_speed)
			icons[i].get_node("AnimationPlayer").play("Appear")
