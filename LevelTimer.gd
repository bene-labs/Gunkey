extends Node2D

export var decimal_places = 2
var passed_time = 0

var is_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = format_time(0.0)
	
func _input(event):
	if not is_started and (Input.is_action_just_pressed("jump") or \
	Input.is_action_just_pressed("move_left") or \
	Input.is_action_just_pressed("move_right") or \
	Input.is_action_just_pressed("shoot_primary") or \
	Input.is_action_just_pressed("shoot_secondary")):
		$Timer.start()
		is_started = true

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
