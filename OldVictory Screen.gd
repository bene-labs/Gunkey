extends Node2D

export var bronze_time = 200
export var silver_time = 120
export var gold_time = 50

export var bronze_kills = 3
export var silver_kills = 5
export var gold_kills = 10

export var bronze_coins = 1
export var silver_coins = 2
export var gold_coins = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D/CanvasLayer.hide()
	
func activate(time, kills, coins):
	var level_rating = 0
	
	$Camera2D/CanvasLayer/Time/ScoreText.text = "Your Time: " + str(time)
	if time <= gold_time:
		$Camera2D/CanvasLayer/Time/Medal.animation = "Gold"
		level_rating += 3
	elif time <= silver_time:
		$Camera2D/CanvasLayer/Time/Medal.animation = "Silver"
		level_rating += 2
	elif time <= bronze_time:
		$Camera2D/CanvasLayer/Time/Medal.animation = "Bronze"
		level_rating += 1
	else:
		$Camera2D/CanvasLayer/Time/Medal.animation = "None"
		
	$Camera2D/CanvasLayer/Kills/ScoreText.text = "Your Kills: " + str(kills)
	if kills >= gold_kills:
		$Camera2D/CanvasLayer/Kills/Medal.animation = "Gold"
		level_rating += 6
	elif kills >= silver_kills:
		$Camera2D/CanvasLayer/Kills/Medal.animation = "Silver"
		level_rating += 5
	elif kills >= bronze_kills:
		$Camera2D/CanvasLayer/Kills/Medal.animation = "Bronze"
		level_rating += 4
	else:
		$Camera2D/CanvasLayer/Kills/Medal.animation = "None"
		
	$Camera2D/CanvasLayer/Coins/ScoreText.text = "Coins Got: " + str(coins)
	if coins >= gold_coins:
		$Camera2D/CanvasLayer/Coins/Medal.animation = "Gold"
		level_rating += 3
	elif coins >= silver_coins:
		$Camera2D/CanvasLayer/Coins/Medal.animation = "Silver"
		level_rating += 2
	elif coins >= bronze_coins:
		$Camera2D/CanvasLayer/Coins/Medal.animation = "Bronze"
		level_rating += 1
	else:
		$Camera2D/CanvasLayer/Coins/Medal.animation = "None"
	
	if level_rating / 3 >= 3:
		$Camera2D/CanvasLayer/Medal.animation = "Gold"
	elif level_rating / 3 >= 2:
		$Camera2D/CanvasLayer/Medal.animation = "Silver"
	elif level_rating / 3 >= 1:
		$Camera2D/CanvasLayer/Medal.animation = "Bronze"
	
	$Camera2D/CanvasLayer.show()
