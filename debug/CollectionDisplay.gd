extends Node2D

var collected = 0 setget set_collected
var total = 0 setget set_total

func set_total(value):
	total = value
	update()

func set_collected(value):
	collected = value
	update()

func update():
	$Label.text = "%d/%d" % [collected, total]
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene.get_node("Collectibles") != null:
		total = get_tree().current_scene.get_node("Collectibles").total_collectibles
	else:
		push_warning("No Collectibles in level!")
