extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	var dir := -1.0 if player.anim.flip_h else 1.0
	player.velocity.x = dir * player.speed * 1.5
	player.play_anim("slide")

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.speed * 2.0)
	player.move_and_slide()

func handle_input(_event: InputEvent) -> void:
	pass  # block all input during slide

# Called by StateMachine when animation_finished fires (wire this up in Knight.gd)
func on_anim_finished() -> void:
	finished.emit(IDLE)
