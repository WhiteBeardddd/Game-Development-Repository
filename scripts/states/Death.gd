extends PlayerState

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO
	player.play_anim("death")
	# Freeze on last frame — do nothing after this
