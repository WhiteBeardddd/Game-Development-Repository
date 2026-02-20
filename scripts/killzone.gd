extends Area2D

@onready var time = $Timer

func _on_body_entered(body):
	print("YOU ARE DEATH!!!")
	time.start()
	


func _on_timer_timeout():
	get_tree().reload_current_scene()
