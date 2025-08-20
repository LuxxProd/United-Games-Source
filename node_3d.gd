extends Node3D

@export var player_scene: PackedScene

func _ready():
	# Register spawnable and the factory
	$MultiplayerSpawner.add_spawnable_scene("player")
	$MultiplayerSpawner.spawn_function = Callable(self, "_spawn_player_scene")

	# Host listens for new peers and spawns for them
	multiplayer.peer_connected.connect(_on_peer_connected)

func _spawn_player_scene(peer_id):
	var node = player_scene.instantiate()
	# Critical: assign input authority based on the single spawn() argument
	node.set_multiplayer_authority(int(peer_id))
	return node

func _on_peer_connected(id):
	# Defer to the next idle frame so MultiplayerSpawner is ready
	call_deferred("_safe_spawn_for_peer", id)

func _safe_spawn_for_peer(id):
	if multiplayer.is_server() \
	and $MultiplayerSpawner.is_inside_tree() \
	and multiplayer.has_multiplayer_peer():
		$MultiplayerSpawner.spawn(id)

func host_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7777)
	multiplayer.multiplayer_peer = peer

func join_game(address: String):
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(address, 7777)
	multiplayer.multiplayer_peer = peer
	# Client does not spawn; host will do it

func _on_MultiplayerSpawner_spawned(node):
	print("Spawned player:", node, "Authority:", node.get_multiplayer_authority())

func _on_host_button_pressed() -> void:
	host_game()

func _on_join_button_pressed() -> void:
	join_game("127.0.0.1")
