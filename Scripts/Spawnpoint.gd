class_name Spawnpoint extends Node2D

var _room : Room

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node = self
	while (node != null && !node is Room):
		node = node.get_parent()

	if node == null:
		push_error(node == null, "The door is not in any room")
		return

	_room = node
	_room.spawnpoints.push_back(self)
	print("Added spawnpoint")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
