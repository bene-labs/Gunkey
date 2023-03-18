extends Node2D

export var default_cursor = preload("res://Sprites/Player/gun_cursor.png")
export var active_cursor = preload("res://Sprites/Player/gun_cursor_active.png")
export var wait_cursor = preload("res://Sprites/Cursor/cursor_load.png")

export var cursor_center = Vector2(25, 25)

var is_destructible_hovered = false

func _ready():
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, cursor_center)
	Input.set_custom_mouse_cursor(active_cursor, Input.CURSOR_IBEAM, cursor_center)
	Input.set_custom_mouse_cursor(wait_cursor, Input.CURSOR_BUSY, cursor_center)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event):
	if not event is InputEventMouseMotion:
		return

	$Area2D.global_position = get_global_mouse_position()
