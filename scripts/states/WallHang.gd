extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.play_anim("wall_hang")

func physics_update(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")

	if player.is_on_floor():
		finished.emit(IDLE)
		return

	if not player.is_on_wall():
		finished.emit(FALL)
		return

	if dir != 0.0 and Input.is_action_pressed("jump"):
		finished.emit(WALL_CLIMB)
	elif dir != 0.0:
		# Wall slide — glide slowly down
		player.velocity.y = player.wall_slide_speed
	else:
		finished.emit(FALL)

	player.move_and_slide()
