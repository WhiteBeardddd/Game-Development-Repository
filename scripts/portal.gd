extends Area2D

@export var level_2_scene: String = "res://scenes/Level2.tscn"
@export var spawn_name: String = "Level2Spawn"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered portal") # DEBUG
		GameManager.spawn_point = spawn_name
		get_tree().change_scene_to_file(level_2_scene)
