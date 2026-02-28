extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.play_anim("jump")  # swap with "fall" anim if you add one

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal(Input.get_axis("move_left", "move_right"))
	player.move_and_slide()

	if player.is_on_wall():
		finished.emit(WALL_HANG)
	elif player.is_on_floor():
		var dir := Input.get_axis("move_left", "move_right")
		finished.emit(RUN if dir != 0.0 else IDLE)
