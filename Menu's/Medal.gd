class_name Medal extends Node2D

var transitioning_to = -1

func show_sprite(medal_value):
	match medal_value:
		0:
			$MedalEmpty.show()
		1:
			$MedalBronze.show()
		2:
			$MedalSilver.show()
		3:
			$Gold.show()
		4:
			$Special.show()
		5:
			$MedalKey.show()
		_:
			$MedalEmpty.show()

func transition_to(medal_value):
	transitioning_to = medal_value
	$AppearDelay.start()


func _on_AppearDelay_timeout():
	$AnimationPlayer.play("Appear_" + str(transitioning_to))
