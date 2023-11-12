extends Node2D

var scene_transition : PackedScene = preload("res://SceneTransition.tscn")
var active_scene_transition : AnimationPlayer = null

func instantiate_transition() -> AnimationPlayer:
	var transition = scene_transition.instance()
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].add_child(transition)
	else:
		get_tree().current_scene.add_child(transition)
	return transition

func animate_fade_in():
	if active_scene_transition == null:
		active_scene_transition = instantiate_transition()
	active_scene_transition.play("FadeIn")
	yield(active_scene_transition, "animation_finished")

func animate_fade_out():
	if active_scene_transition == null:
		active_scene_transition = instantiate_transition()
	active_scene_transition.play("FadeOut")

func transition_to(_next_scene, is_animated = true):
	if is_animated:
		yield(animate_fade_in(), "completed")
	active_scene_transition = null
	get_tree().change_scene(_next_scene)
	if is_animated:
		yield(get_tree(), "idle_frame")
		animate_fade_out()

func reload_current_scene(is_animated = true):
	if is_animated:
		yield(animate_fade_in(), "completed")
	active_scene_transition = null
	get_tree().reload_current_scene()
	if is_animated:
		yield(get_tree(), "idle_frame")
		animate_fade_out()

func simulate_transition(node_to_pass_to):
	yield(animate_fade_in(), "completed")
	$SameSceneTransitionDelay.start()
	yield($SameSceneTransitionDelay, "timeout")
	active_scene_transition = scene_transition.instance()
	node_to_pass_to.add_child(active_scene_transition)
	animate_fade_out()

