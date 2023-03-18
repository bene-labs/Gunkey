extends Node2D

var construction_data = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child.has_method("get_construction_data"):
			construction_data.append(child.get_construction_data())

func get_construction_data():
	construction_data.clear()
	for child in get_children():
		if child.has_method("get_construction_data"):
			construction_data.append(child.get_construction_data())
	return construction_data

func custom_duplicate(flag = 0):
	var new_copy = Node2D.new()
	new_copy.name = "Enemies"
	for child in get_children():
		if not child.has_method("custom_duplicate"):
			continue
		new_copy = duplicate_rec(child, new_copy, flag)
	new_copy.set_script(load("res://EnemyScenes/Enemies.gd"))
	return new_copy
	
func duplicate_rec(src : Node, dest : Node, flag = 0):
	for child in src.get_children():
		if not child.has_method("custom_duplicate"):
			continue
		child = duplicate_rec(child, src, flag)
	var src_name = src.name
	var dest_name = dest.name
	dest.add_child(src.custom_duplicate(flag))
	return dest
