extends Area2D

@onready var time = $Timer

func _on_body_entered(body):
	if body.is_in_group("player"):
		# If touched by slime killzone = damage, if fall killzone = instant death
		var parent = get_parent()
		if parent.is_in_group("enemy"):
			body.hurtByEnemy(self)
			if body.currentHealth <= 0:
				_die(body)
		else:
			# Fell off map = instant death
			_die(body)

func _die(body):
	print("YOU DIED!!!")
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	time.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
