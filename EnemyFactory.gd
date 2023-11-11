extends Node

var templates = []
var construction_data = [] 

func is_path_in_templates(path):
	for template in templates:
		if template["Path"] == path:
			return true
	return false

func get_template_by_path(path):
	for template in templates:
		if template["Path"] == path:
			return template["Data"]
	return null

func generate_enemy_templates(constr_data):
	templates.clear()
	construction_data = constr_data
	for data in construction_data:
		if not is_path_in_templates(data["Path"]):
			templates.append({"Path": (data["Path"]), "Data": load(data["Path"])})
		
func set_construction_data(value):
	construction_data = value

func construct_enemies(dest, origin_point = Vector2.ZERO, min_distance = -1):
	for data in construction_data:
		var new_enemy = get_template_by_path(data["Path"]).instance()
		if min_distance >= 0 and data["Type"] != "Turret" and data["Type"] != "Walker":
			if origin_point.distance_to(data["Position"]) <= min_distance:
				continue
		if not is_instance_valid(new_enemy):
			push_error("Cannot construt Enemy of type" + data["Type"] + ": Path '" + data["Path"] + "' is invalid!")
			continue
		match data["Type"]:
			"Walker":
				new_enemy.direction = data["Direction"]
			"Turret":
				new_enemy.sprite_rotation = data["SpriteRotation"]
			_:
				pass
		dest.add_child(new_enemy)
		new_enemy.global_position = data["Position"]
