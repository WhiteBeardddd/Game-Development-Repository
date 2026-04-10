extends Node

var Players: Dictionary = {}
var my_id: int = 0

func add_player(id: int) -> void:
	if !Players.has(id):
		Players[id] = {"name": id, "ready": 0}

func set_ready(id: int) -> void:
	if Players.has(id):
		Players[id].ready = 1

func all_ready() -> bool:
	if Players.size() < 2:
		return false
	for id in Players:
		if Players[id].ready != 1:
			return false
	return true
