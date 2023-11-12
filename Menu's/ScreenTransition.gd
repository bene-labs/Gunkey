extends Node2D

signal fade_in_completed

export var self_activate = false

func _ready():
	if self_activate:
		activate()


func transition_to(_next_scene):
	SaveState.set_is_transition_queded(true)
	$AnimationPlayer.play("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(_next_scene)
	
func transition_to_restart():
	SaveState.set_is_transition_queded(true)
	$AnimationPlayer.play("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	get_tree().reload_current_scene()

func simulate_transition():
	$AnimationPlayer.play("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	$SameSceneTransitionDelay.start()
	
func activate():
	if SaveState.is_transition_queded:
		SaveState.set_is_transition_queded(false)
		$AnimationPlayer.play("FadeOut")

func _on_SameSceneTransitionDelay_timeout():
	emit_signal("fade_in_completed")
	$AnimationPlayer.play("FadeOut")
