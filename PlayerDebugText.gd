extends Label

export (NodePath) var player_path

var player : Player = null

func _ready():
	player = get_node_or_null(player_path)
	if not is_instance_valid(player):
		push_error("Cannot display Player Debug text. Invalid Player Path!")
		queue_free()
	if not OS.is_debug_build():
		queue_free()

func _process(delta):
	var collision_str = ""
	
	for i in player.get_slide_count():
		var collision = player.get_slide_collision(i)
		collision_str += collision.collider.name + ", "
	
	text = "Velcoity: (%3.2f, %3.2f)\nIs on ground: %s\nTouches Wall: %s\nTouches Celling: %s\nColliding with %s" \
	% [player.get_node("Movement").velocity.x, player.get_node("Movement").velocity.y, player.is_on_floor(), player.is_on_wall(), player.is_on_ceiling(), collision_str]

func pause():
	set_process(false)
	
func unpause():
	set_process(true)
