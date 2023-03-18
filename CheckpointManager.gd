extends Node2D

export (NodePath) var enemies_path
export (NodePath) var collectibles_path
export (NodePath) var barrels_path = ""
export (NodePath) var player_path

var explosive_barrel_template = preload("res://ExplosiveBarrel.tscn")

var activated_checkpoints = []
var selected_checkpoint = null

var barrels_data = []
var enemy_back_up = null
var keys_back_up = null

var keys_collected = 0
var collection_count = 0
var kills = 0

#var enemies_to_reset = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Checkpoint:
			child.connect("activated", self, "_on_checkpoint_activated")

func _on_checkpoint_activated(checkpoint):
	activated_checkpoints.append(checkpoint)
	selected_checkpoint = checkpoint
#	enemy_back_up = get_node(enemies_path).custom_duplicate(15)
	keys_back_up = get_node(collectibles_path).custom_duplicate(15)
	keys_collected = get_node(player_path).get_collected_keys()
	collection_count = get_node(player_path).collection_count
	kills = get_node(player_path).get_kills()
	
	if is_instance_valid(get_node_or_null(barrels_path)):
		barrels_data.clear()
		for barrel in get_node(barrels_path).get_children():
			barrels_data.append({"Position": barrel.global_position})
	pass
	
func reset_enemies():
	var enemies = get_node(enemies_path)
	for enemy in enemies.get_children():
		enemies.remove_child(enemy)
		enemy.queue_free()
	$EnemyFactory.construct_enemies(get_node(enemies_path))
#	get_node(enemies_path).queue_free()
#	var new_enemies = enemy_back_up.custom_duplicate(15)
#	get_tree().root.get_child(3).add_child(new_enemies)
#	enemies_path = new_enemies.get_path()

func reset_keys():
	get_node(collectibles_path).queue_free()
	var new_keys = keys_back_up.custom_duplicate(15)
	get_tree().root.get_child(3).add_child(new_keys)
	new_keys.name = "Collectibles"
	collectibles_path = new_keys.get_path()
	
func restore_barrels():
	if not is_instance_valid(get_node_or_null(barrels_path)):
		return
	var barrels = get_node(barrels_path)
	for barrel in barrels.get_children():
		barrels.remove_child(barrel)
		barrel.queue_free()
	for data in barrels_data:
		var new_barrel = explosive_barrel_template.instance()
		new_barrel.global_position = data["Position"]
		barrels.add_child(new_barrel)

func remove_projectiles():
	for projectile in get_tree().get_nodes_in_group("Projectile"):
		projectile.queue_free()

func respawn(player: Player) -> bool:
	if not selected_checkpoint is Checkpoint:
		return false
	player.global_position = selected_checkpoint.get_spawn_position()
	player.reset()
	player.unpause()
	reset_enemies()
	reset_keys()
	restore_barrels()
	remove_projectiles()
	get_node(player_path).collection_count = collection_count
	get_node(player_path).set_collected_keys(keys_collected)
	get_node(player_path).set_kills(kills)
	return true
