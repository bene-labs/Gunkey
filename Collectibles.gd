extends Node2D

var total_collectibles = 0
var collected = 0

var collectibles = []

var is_ready = false

func custom_duplicate(flag = 0):
#	print("Duplicated ", name)
	
	var new_copy = duplicate(flag)
	new_copy.collectibles = collectibles
#	for i in range(len(collectibles)):
#		new_copy.collectibles[i].was_already_collected = collectibles[i].was_already_collected
	new_copy.is_ready = is_ready
	new_copy.total_collectibles = total_collectibles
	new_copy.collected = collected
	return new_copy
	

func _ready():
	if is_ready:
		return
	for child in get_children():
		if child is Collectible:
			total_collectibles += 1
			child.connect("collected", self, "_on_collectible_collected", [child])
			collectibles.append(child)
	 get_tree().root.get_child(3).get_node("Player").set_key_total(total_collectibles)
	collectibles.sort_custom(self, "compare_x_position")
	for i in range(len(collectibles)):
		if SaveState.progress.data["Levels"][get_tree().root.get_child(3).level_number - 1]["Keys"][i] == true:
			collectibles[i].mark_collected()
			collected += 1
			get_tree().root.get_child(3).get_node("Player").increase_collection_counter()
			get_tree().root.get_child(3).get_node("Player").collection_count = 0
	is_ready = true

func compare_x_position(a, b):
	return a.global_position.x < b.global_position.x

func _on_collectible_collected(collectible):
	collected += 1
	for collect in collectibles:
		if not is_instance_valid(collect):
			continue
		if collect.name == collectible.name:
			collect = null
