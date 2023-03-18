extends Node2D

var paused = false
var active = false

export (bool) var show_sprite = false

func _ready():
	$StaticBody2D/CollisionShape2D.disabled = true
	if not show_sprite:
		$Sprite.hide()

func _process(delta):
	if active and Input.is_action_pressed("drop_down"):
		disable()
		paused = true
		$PauseTimer.start()

func _on_PauseTimer_timeout():
	paused = false

func enable():
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", false) 
	active = true

func disable():
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true) 
	active = false

func _on_ActivationArea_area_entered(area):
	if paused:
		return
	if area.name == "FeetArea":
		enable()

func _on_ActivationArea_area_exited(area):
	if paused:
		return
	if area.name == "FeetArea":
		disable()

func pause():
	set_process(false)
	
func unpause():
	set_process(true)
