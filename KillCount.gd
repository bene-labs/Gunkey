extends Node2D

var kills = 0 setget set_kills

func on_kill():
	kills += 1
	$Label.text = "Kills: " + str(kills)
	
func set_kills(value):
	kills = value
	$Label.text = "Kills: " + str(kills)
