extends PlayerState

const ROLL_DURATION := 0.4
var timer := 0.0
var dir   := 1.0

func enter(_prev: String, _data: Dictionary = {}) -> void:
	timer = ROLL_DURATION
	dir   = -1.0 if player.anim.flip_h else 1.0
	player.play_anim("roll")

func physics_update(delta: float) -> void:
	timer -= delta
	player.velocity.x = dir * player.roll_speed
	player.velocity.y = 0.0
	player.move_and_slide()

	if timer <= 0.0:
		finished.emit(IDLE)
