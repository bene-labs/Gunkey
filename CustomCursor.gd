extends Node2D

export var default_cursor = preload("res://Sprites/Player/gun_cursor.png")
export var active_cursor = preload("res://Sprites/Player/gun_cursor_active.png")

export var cursor_center = Vector2(25, 25)

export (bool) var respect_player_range = true
export (NodePath) var player_path
var player : Player = null

var is_destructible_hovered = false

#var destructibles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, cursor_center)
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_BUSY, cursor_center)
	
#	Input.set_custom_mouse_cursor(active_cursor, Input.CURSOR_CROSS, cursor_center)
	player = get_node_or_null(player_path)


func _input(event):
	if not event is InputEventMouseMotion:
		return
#	if len(destructibles) == 0:
#		setup_destructibles()
#
	var target_found = false
	$Area2D.global_position = get_global_mouse_position()
#	for target in destructibles:
#		if target.b

func pause():
	set_process(false)
	set_process_input(false)
	
func unpause():
	set_process(true)
	set_process_input(true)

func _process(delta):
	var overlaps_destructilbe = false
	
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Destructible"):
			if respect_player_range and not player.is_inside_range(get_global_mouse_position()):
				continue
			overlaps_destructilbe = true
			break
	
	if overlaps_destructilbe and not is_destructible_hovered:
		Input.set_custom_mouse_cursor(active_cursor, Input.CURSOR_ARROW, cursor_center)
		is_destructible_hovered = true
	elif not overlaps_destructilbe and is_destructible_hovered:
		Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, cursor_center)
		is_destructible_hovered = false
		
#func _on_Area2D_body_entered(body):
#	if body.is_in_group("Destructible"):
##		print(">>>ENTER BODY:", body.name)
#		if respect_player_range and get_global_mouse_position().distance_to(player.global_position) > player.get_range():
#			return
#		Input.set_custom_mouse_cursor(active_cursor, Input.CURSOR_ARROW, cursor_center)
#
#func _on_Area2D_body_exited(body):
#	if body.is_in_group("Destructible"):
#		if len($Area2D.get_overlapping_bodies()) == 0:
##			print("<<<EXIT BODY: ", body.name)
#			Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, cursor_center)
