extends TextureProgress

enum HealthStates {
	FULL,
	MEDIUM,
	LOW,
	VERY_LOW,
}

export var medium_health = 75
export var low_health = 50
export var very_low_health = 20

export var colors = []

func _on_HealthBar_value_changed(value):
	value = value
	
	var percantage = value / max_value * 100
	
	if percantage <= very_low_health:
		self_modulate = colors[-1]
	elif percantage <= low_health:
		self_modulate = colors[-2]
	elif percantage <= medium_health:
		self_modulate = colors[-3]
	else:
		self_modulate = colors[0]
