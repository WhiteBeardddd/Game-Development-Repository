extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	player.play_anim("attack1")

func handle_input(event: InputEvent) -> void:
	# Buffer combo during attack1
	if event.is_action_pressed("attack1") and player.combo_timer > 0.0:
		player.attack_combo = 2

func physics_update(delta: float) -> void:
	player.combo_timer = maxf(player.combo_timer - delta, 0.0)
	player.apply_gravity(delta)
	player.move_and_slide()
