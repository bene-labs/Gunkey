extends Node2D

func pause():
	$AnimatedSprite.playing = false
	
func unpause():
	$AnimatedSprite.playing = true
