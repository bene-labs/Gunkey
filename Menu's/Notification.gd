extends Node2D

export var life_time = 3.0
export var fade_out_speed = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.self_modulate.a = 0
	$Timer.wait_time = life_time

func create(text, disappear_after = life_time):
	$Label.text = text
	$Label.self_modulate.a = 255
	$Timer.start(disappear_after)
	
func _on_Timer_timeout():
	$AnimationPlayer.play("FadeOut")

func pause():
	$Timer.paused = true
	
func unpause():
	$Timer.paused = false
