extends Node2D
export (PackedScene) var enemy_scene
export var spawn_delay = 10.0
export (bool) var spawn_on_start = true
export var spawn_delay_decrease = 0.25
export var min_spawn_delay = 2.5

var spawn_positons = []

func _ready():
	$Timer.wait_time = spawn_delay
	$Timer.start()
	
	for child in get_children():
		if child is Position2D:
			spawn_positons.append(child)
	
	if spawn_on_start:
		spawn_enemy()

func spawn_enemy():
	var position = spawn_positons[randi() % len(spawn_positons)].position
	var enemy = enemy_scene.instance()
	enemy.global_position = position
	 get_tree().current_scene.call_deferred("add_child", enemy)
	$Timer.wait_time += spawn_delay_decrease
	
func _on_Timer_timeout():
	spawn_enemy()
	
	
func pause():
	$Timer.paused = true
	
func unpause():
	$Timer.paused = false


