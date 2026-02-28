extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.velocity.y = player.jump_velocity
	player.play_anim("jump")

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal(Input.get_axis("move_left", "move_right"))
	player.move_and_slide()

	if player.is_on_wall():
		finished.emit(WALL_HANG)
	elif player.velocity.y >= 0.0:
		finished.emit(FALL)
