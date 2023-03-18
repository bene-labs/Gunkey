class_name Checkpoint extends Node2D

export var heal_ammount = 5

var is_activated = false

var activation_time = 0

signal activated

func _on_ActivationArea_body_entered(body):
	if body is Player:
		activation_time = body.get_passed_time()
		body._on_checkpoint_activated()
		body.heal(heal_ammount)
		is_activated = true
		$Mast/ActivationArea.queue_free()
		$AnimationPlayer.play("activate")
		$ActivateSound.play()
		emit_signal("activated", self)

func get_spawn_position():
	return $RespawnPoint.global_position
