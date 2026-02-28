extends PlayerState

const DASH_DURATION := 0.2
var timer := 0.0
var dir   := 1.0

func enter(_prev: String, _data: Dictionary = {}) -> void:
	timer = DASH_DURATION
	dir   = -1.0 if player.anim.flip_h else 1.0
	player.play_anim("dash")

func physics_update(delta: float) -> void:
	timer -= delta
	player.velocity.x = dir * player.dash_speed
	player.velocity.y = 0.0
	player.move_and_slide()

	if timer <= 0.0:
		finished.emit(IDLE)
