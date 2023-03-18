class_name Collectible extends Area2D

signal collected

export (Curve) var hover_curve = Curve.new()
export (float) var hover_speed = 2.0
onready var hover_timer = $HoverTimer

export var enable_hover = false

export var was_already_collected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if enable_hover:
		hover_curve.bake()
	else:
		$HoverTimer.stop()
		
func mark_collected():
	$Sprite.hide()
	$GhostSprite.show()
	$Sparkles.self_modulate = $GhostSprite.self_modulate
	$KeyCollect.self_modulate = $GhostSprite.self_modulate
	was_already_collected = true
	
func _on_Collectible_body_entered(body):
	if body.has_method("increase_collection_counter"):
		if not was_already_collected:
			body.increase_collection_counter()
			$Sprite.hide()
		else:
			body.increase_collection_counter(true)
			$GhostSprite.hide()
		collision_layer = 0
		collision_mask = 0
		$AudioStreamPlayer2D.play()
		$KeyCollect.emitting = true

func _process(delta):
	if enable_hover:
		if was_already_collected:
			$GhostSprite.position.y = hover_curve.interpolate(1 - (hover_timer.wait_time - hover_timer.time_left) / hover_timer.wait_time)
		else:
			$Sprite.position.y = hover_curve.interpolate(1 - (hover_timer.wait_time - hover_timer.time_left) / hover_timer.wait_time)

func _on_AudioStreamPlayer2D_finished():
	queue_free()

func pause():
	set_process(false)
	
func unpause():
	set_process(true)
