extends Node2D
const KnightScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	print("=== LEVEL 1 READY ===")
	print("My ID: " + str(multiplayer.get_unique_id()))
	print("Players: ", NakamaMultiplayer.Players)

	multiplayer.peer_connected.connect(_on_peer_connected)

	var i = 0
	for id in NakamaMultiplayer.Players:
		_spawn_player(id, i)
		i += 1

func _on_peer_connected(id: int) -> void:
	print("Late peer connected: " + str(id))
	if !NakamaMultiplayer.Players.has(id):
		NakamaMultiplayer.Players[id] = {"name": id, "ready": 1}
	_spawn_player(id, NakamaMultiplayer.Players.size() - 1)

func _spawn_player(id: int, index: int) -> void:
	if get_node_or_null("Players/" + str(id)) != null:
		print("Already spawned: " + str(id))
		return
	print("Spawning knight for ID: " + str(id))
	var knight = KnightScene.instantiate()
	knight.name = str(id)
	knight.position = $Level1spawn.position + Vector2(index * 50, 0)
	$Players.add_child(knight)
	knight.set_multiplayer_authority(id)
	var local_id = multiplayer.get_unique_id()
	if id != local_id:
		knight.set_process_input(false)
		knight.set_physics_process(false)
	print("Spawned: " + str(id) + " | is_local: " + str(id == local_id))
