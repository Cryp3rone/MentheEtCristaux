class_name Room_Generator extends Node2D

static var Instance : Room_Generator

@export var map_size : Vector2i
@export var rooms : Array[PackedScene]
@export var room_node : Node2D

var room_North : Array[PackedScene]
var room_South : Array[PackedScene]
var room_East : Array[PackedScene]
var room_West : Array[PackedScene]

var has_end_generation : bool

var random = RandomNumberGenerator.new()

func _init() -> void:
	Instance = self

func _ready() -> void:
	load_all_rooms()


func load_all_rooms() -> void:
	var index = 0
	for room in rooms:
		var room_instantiate = rooms[index].instantiate()
		room_node.add_child(room_instantiate)
		index += 1

		if index >= rooms.size():
			print("Rooms size : ", rooms.size(), " ; index : ", index)
			room_instantiate.all_rooms.clear()

	call_deferred("start_generation")

		

func start_generation() -> void:
	has_end_generation = false
	var random_index = random.randi_range(0,rooms.size()-1)
	var room_instantiate = rooms[random_index].instantiate()
	room_instantiate.is_start_room = true;
	room_instantiate.position = Vector2.ZERO
	room_node.add_child(room_instantiate)
	print("Starter Room instantiated")

func get_opposite_room_from_orientation(orientation : Utils.ORIENTATION) -> PackedScene:
	match orientation:
		Utils.ORIENTATION.NORTH:
			var random_index = random.randi_range(0, room_South.size() - 1)
			return room_South[random_index]
		Utils.ORIENTATION.SOUTH:
			var random_index = random.randi_range(0, room_North.size() - 1)
			return room_North[random_index]
		Utils.ORIENTATION.EAST:
			var random_index = random.randi_range(0, room_West.size() - 1)
			return room_West[random_index]
		Utils.ORIENTATION.WEST:
			var random_index = random.randi_range(0, room_East.size() - 1)
			return room_East[random_index]
		Utils.ORIENTATION.NONE:
			return null
	
	return null
