class_name AnimationHelper extends Node

static func reconfige_animation_lenght(animation: Animation, new_length):
	var old_length = animation.length
	var transfer_values = []
	
	animation.length = new_length
	
	if old_length == new_length:
		return
	
	for i in range(animation.get_track_count()):
		var key_idx = animation.track_find_key(i, old_length)
		var key_value = animation.track_get_key_value(i, key_idx)
		animation.track_remove_key(i, key_idx)
		animation.track_insert_key(i, new_length, key_value)

static func reconfige_even_timed_animation_lenght(animation: Animation, new_length, time_stamps):
	var old_length = animation.length
	var transfer_values = []
	
	if old_length == new_length:
		return
	
	animation.length = new_length
	
#	print(animation.resource_name, "\n###########")
	for i in range(animation.get_track_count()):
		for j in range(len(time_stamps) - 1, 0, -1):
			var time = time_stamps[j]
			var key_idx = animation.track_find_key(i, time, true)
			if key_idx < 0:
				continue
			var key_value = animation.track_get_key_value(i, key_idx)
			animation.track_remove_key(i, key_idx)
			var new_time = time * (new_length / old_length)
#			print("Time: ", time, "-> New Time:", new_time, " Value: ", key_value)
			animation.track_insert_key(i, new_time, key_value)

static func generate_even_timed_animation_with_new_lenght(animation: Animation, new_length, time_stamps) -> Animation:
	var old_length = animation.length
	var transfer_values = []
	var new_animation = Animation.new()
	
	animation.length = new_length
	
	for i in range(animation.get_track_count()):
		new_animation.add_track(animation.track_get_type(i))
		for time in time_stamps:
			var key_idx = animation.track_find_key(i, time)
			var key_value = animation.track_get_key_value(i, key_idx)
#			animation.track_remove_key(i, key_idx)
			var new_time = time * (new_length / old_length)
			new_animation.track_insert_key(i, new_time, key_value)
			
	return new_animation

static func reconfige_complex_animation_lenght(animation: Animation, new_length, time_stamps):
	var old_length = animation.length
	var transfer_values = []
	
	animation.length = new_length
	
	for i in range(animation.get_track_count()):
		for time in time_stamps[i]:
			var key_idx = animation.track_find_key(i, time)
			var key_value = animation.track_get_key_value(i, key_idx)
			animation.track_remove_key(i, key_idx)
			var new_time = time * (new_length / old_length)
			animation.track_insert_key(i, new_length, key_value)
