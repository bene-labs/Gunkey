extends Area2D

signal win

var is_won = false

func _on_VictoryZone_body_entered(body):
	if body is Player and not is_won:
		is_won = true
		emit_signal("win")


func _on_VictoryZone_win():
	pass # Replace with function body.
