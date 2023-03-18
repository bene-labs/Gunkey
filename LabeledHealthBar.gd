extends Node2D

enum HealthStates {
	FULL,
	MEDIUM,
	LOW,
	VERY_LOW,
}

export var medium_health = 75
export var low_health = 50
export var very_low_health = 20

# high to low health
export var textures = []
export var icons = []

func _on_HealthBar_value_changed(value):
	value = value
	
	var percantage = $HealthBar.value /  $HealthBar.max_value * 100
	
	if percantage <= very_low_health:
		$HealthBar.texture_progress = textures[-1]
		$Icon.texture = icons[-1]
	elif percantage <= low_health:
		$HealthBar.texture_progress = textures[-2]
		$Icon.texture = icons[-2]
	elif percantage <= medium_health:
		$HealthBar.texture_progress = textures[-3]
		$Icon.texture = icons[-3]
	else:
		$HealthBar.texture_progress = textures[0]
		$Icon.texture = icons[0]
	$Label.text = str($HealthBar.value) + "/" + str($HealthBar.max_value)
