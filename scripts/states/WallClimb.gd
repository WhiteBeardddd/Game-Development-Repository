extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.play_anim("wall_climb")

func physics_update(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	player.velocity.y = player.wall_climb_speed
	player.move_and_slide()

	if not Input.is_action_pressed("jump") or not player.is_on_wall():
		finished.emit(FALL)
	elif dir == 0.0:
		finished.emit(WALL_HANG)
