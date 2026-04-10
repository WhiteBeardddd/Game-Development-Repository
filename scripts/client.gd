extends Control
class_name NakamaMultiplayer

var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var createdMatch
var multiplayerBridge : NakamaMultiplayerBridge

static var Players = {}  # <-- static, persists across scene changes

signal OnStartGame()

func _ready() -> void:
	OnStartGame.connect(_on_start_game)

func _on_start_game():
	print("=== LOADING LEVEL ===")
	var root = get_tree().get_root()
	get_parent().remove_child(self)
	root.add_child(self)
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func updateUserInfo(username, displayname, avatarurl = "", language = "en", location = "us", timezone = "est"):
	await client.update_account_async(session, username, displayname, avatarurl, language, location, timezone)

func onMatchPresence(presence : NakamaRTAPI.MatchPresenceEvent):
	print(presence)

func onMatchState(state : NakamaRTAPI.MatchData):
	print(state.data)

func onSocketConnected():
	print("Socket Connected")

func onSocketClosed():
	print("Socket Closed")

func onSocketReceivedError(err):
	print("Socket Error: " + str(err))

func _process(_delta: float) -> void:
	pass

func _on_login_button_button_down() -> void:
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")

	session = await client.authenticate_email_async($Panel2/EmailInput.text, $Panel2/PasswordInput.text)
	if session.is_exception():
		print("Auth failed: ", session.get_exception().message)
		return

	socket = Nakama.create_socket_from(client)
	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketReceivedError)
	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)
	await socket.connect_async(session)

	updateUserInfo("test", "testDisplay")
	var account = await client.get_account_async(session)

	$Panel/UserAccountText.text = account.user.username
	$Panel/DisplayNameText.text = account.user.display_name

	setupMultiplayerBridge()
	print(account)

func setupMultiplayerBridge():
	multiplayerBridge = NakamaMultiplayerBridge.new(socket)
	multiplayerBridge.match_join_error.connect(onMatchJoinError)
	multiplayerBridge.match_joined.connect(onMatchJoin)
	var mp = get_tree().get_multiplayer()
	mp.set_multiplayer_peer(multiplayerBridge.multiplayer_peer)
	mp.peer_connected.connect(onPeerConnected)
	mp.peer_disconnected.connect(onPeerDisconnected)
	print("Bridge setup complete")

func onPeerConnected(id):
	print("=== PEER CONNECTED: " + str(id))
	if id <= 0:
		return
	if id != multiplayer.get_unique_id() and !Players.has(id):
		Players[id] = {"name": id, "ready": 0}
	var local_id = multiplayer.get_unique_id()
	if local_id > 0 and !Players.has(local_id):
		Players[local_id] = {"name": local_id, "ready": 0}
	print("Players now: ", Players)

	# If game already in progress, notify the late joiner
	if get_tree().get_nodes_in_group("InGame").size() > 0 and multiplayer.is_server():
		notifyGameInProgress.rpc_id(id)

func onPeerDisconnected(id):
	print("Peer disconnected: " + str(id))
	if Players.has(id):
		Players.erase(id)
	if is_inside_tree() and multiplayer.has_multiplayer_peer():
		playerDisconnected.rpc(id)

func onMatchJoinError(error):
	print("Unable to join match: " + error.message)
	$Panel4/JoinCreateMatch.disabled = false

func onMatchJoin():
	print("=== MATCH JOINED ===")
	print("Match ID: " + multiplayerBridge.match_id)
	print("My peer ID: " + str(multiplayer.get_unique_id()))
	print("Is server: " + str(multiplayer.is_server()))

	var uniqueId = multiplayer.get_unique_id()
	if uniqueId > 0 and !Players.has(uniqueId):
		Players[uniqueId] = {"name": uniqueId, "ready": 0}
	print("Players after join: ", Players)

func _on_join_create_match_button_down() -> void:
	if multiplayerBridge == null:
		print("ERROR: Login first!")
		return
	if multiplayerBridge.match_id != "":
		print("Already in a match!")
		return
	var match_name = $Panel4/LineEdit.text
	if match_name == "":
		print("ERROR: Enter a match name!")
		return

	Players.clear()

	print("Joining match: " + match_name)
	multiplayerBridge.join_named_match(match_name)
	$Panel4/JoinCreateMatch.disabled = true

func _on_ready_button_button_down():
	print("=== READY BUTTON PRESSED ===")
	print("My ID: " + str(multiplayer.get_unique_id()))
	print("Players: ", Players)
	if multiplayer.get_unique_id() <= 0:
		print("ERROR: Not in a match yet!")
		return
	$Panel4/ReadyButton.disabled = true
	Ready.rpc(multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func Ready(id):
	if id <= 0:
		return
	if !Players.has(id):
		Players[id] = {"name": id, "ready": 0}
	Players[id].ready = 1
	print("Player " + str(id) + " is ready")

	if multiplayer.is_server():
		var readyCount = 0
		for i in Players:
			if Players[i].ready == 1:
				readyCount += 1
		print("Ready: " + str(readyCount) + "/" + str(Players.size()))
		if Players.size() >= 2 and readyCount == Players.size():
			print("All ready! Starting game...")
			StartGame.rpc()

@rpc("any_peer", "call_local")
func StartGame():
	print("=== START GAME ===")
	print("Players at start: ", Players)
	OnStartGame.emit()

@rpc("any_peer", "call_local")
func playerDisconnected(id):
	var player_node = get_tree().get_root().get_node_or_null(str(id))
	if player_node:
		player_node.queue_free()

@rpc("any_peer")
func notifyGameInProgress():
	print("Received: game in progress")
	var unique_id = multiplayer.get_unique_id()
	if unique_id <= 0:
		return
	if !Players.has(unique_id):
		Players[unique_id] = {"name": unique_id, "ready": 1}
	else:
		Players[unique_id].ready = 1
	OnStartGame.emit()
	hide()

func _on_store_data_button_down():
	if client == null or session == null or session.is_exception():
		print("ERROR: Not connected. Login first!")
		return
	var saveGame = {
		"name": "username",
		"items": [{"id":1,"name":"gun","ammo":10},{"id":2,"name":"sword","ammo":0}],
		"level": 10
	}
	var result = await client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new("saves", "savegame2", 1, 1, JSON.stringify(saveGame), "")
	])
	if result.is_exception():
		print("error: " + str(result))
		return
	print("Stored data successfully!")

func _on_get_data_button_down():
	if client == null or session == null or session.is_exception():
		print("ERROR: Not connected. Login first!")
		return
	var result = await client.read_storage_objects_async(session, [
		NakamaStorageObjectId.new("saves", "savegame", session.user_id)
	])
	if result.is_exception():
		print("error: " + str(result))
		return
	for i in result.objects:
		print(i.value)

func _on_list_data_button_down():
	var dataList = await client.list_storage_objects_async(session, "saves", session.user_id, 5)
	for i in dataList.objects:
		print(i)

func _on_ping_button_down() -> void:
	var data = {"hello": "world"}
	socket.send_match_state_async(createdMatch.match_id, 1, JSON.stringify(data))

@rpc("any_peer")
func sendData(message):
	print(message)
