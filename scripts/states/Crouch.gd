extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.play_anim("crouch")
	player.velocity.x = 0.0

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()

	if not Input.is_action_pressed("crouch") or not player.is_on_floor():
		finished.emit(IDLE)
	elif Input.is_action_just_pressed("attack1"):
		finished.emit(CROUCH_ATTACK)
	elif Input.get_axis("move_left", "move_right") != 0.0:
		finished.emit(CROUCH_WALK)
