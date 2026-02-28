extends ProgressBar

var player: Player

func _ready():
	# Finds player automatically anywhere in the scene
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.HealthChanged.connect(update_health)
		update_health()
	else:
		print("ProgressBar: Player not found!")

func update_health():
	value = float(player.currentHealth) * 100.0 / float(player.MaxHealth)
