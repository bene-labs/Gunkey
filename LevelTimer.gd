extends Node2D

export var decimal_places = 2
var passed_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func format_time(time_in_sec):
	var seconds = int(time_in_sec)%60
	var minutes = (int(time_in_sec)/60)%60
	var hours = (int(time_in_sec)/60)/60
	var mili_seconds = time_in_sec - int(time_in_sec)
	mili_seconds *= 100
	mili_seconds = int(mili_seconds)
	return "%02d:%02d.%02d" % [minutes, seconds, mili_seconds]

func _on_LevelTimer_timeout():
		passed_time += $Timer.wait_time
		$Label.text = format_time(passed_time)

func on_level_cleared():
	$Label.set("custom_colors/font_color", Color.yellow)
	$Timer.stop()

func pause():
	$Timer.paused = true

func unpause():
	$Timer.paused = false
