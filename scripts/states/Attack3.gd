extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	player.attack_combo = 0
	player.play_anim("attack3")

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
