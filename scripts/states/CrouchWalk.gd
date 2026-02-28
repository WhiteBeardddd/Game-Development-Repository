extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.play_anim("crouch_walk")

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	var dir := Input.get_axis("move_left", "move_right")
	# Half speed while crouching
	if dir != 0.0:
		player.velocity.x = dir * player.speed * 0.5
		player.anim.flip_h = dir < 0.0
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.speed)
	player.move_and_slide()

	if not Input.is_action_pressed("crouch") or not player.is_on_floor():
		finished.emit(RUN)
	elif Input.is_action_just_pressed("attack1"):
		finished.emit(CROUCH_ATTACK)
	elif dir == 0.0:
		finished.emit(CROUCH)
