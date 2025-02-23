class_name Room extends Node2D

@export var is_start_room: bool
# Position of the room in index coordinates. Coordinates {0,0} are the coordinates of the central room. Room {1,0} is on the right side of room {0,0}.
@export var room_pos: Vector2i = Vector2i.ZERO
# Size of the room in index coordinates. By default : {1,1}.
@export var room_size: Vector2i = Vector2i.ONE
@export var tilemap_layers: Array[TileMapLayer]
@export var room_test: PackedScene

static var all_rooms: Array[Room]

var doors: Array[Door]
var spawnpoints : Array[Spawnpoint]
var room_generator = Room_Generator.Instance
var file_path: String
var is_generated: bool
var origin: Utils.ORIENTATION

var can_add_room_north : bool = true
var can_add_room_south : bool = true
var can_add_room_east : bool = true
var can_add_room_west : bool = true

var random = RandomNumberGenerator.new()

@onready var _cam: CameraFollow = $/root/MainScene/Camera2D


func _ready() -> void:
	all_rooms.push_back(self)

	if is_start_room:
		Player.Instance.enter_room(self)
		call_deferred("generate_room")
	elif is_generated:
		call_deferred("generate_room")
		call_deferred("spawn_enemy")
	else:
		call_deferred("load_doors_direction")

func load_doors_direction() -> void:
	file_path = get_scene_file_path()
	for door in doors:
		match door.orientation:
			Utils.ORIENTATION.NORTH:
				if !room_generator.room_North.has(load(file_path)):
					room_generator.room_North.push_back(load(file_path))
					print("Chemin packed : ", file_path, "; room north : ", room_generator.room_North.size())
			Utils.ORIENTATION.SOUTH:
				if !room_generator.room_South.has(load(file_path)):
					room_generator.room_South.push_back(load(file_path))
					print("Chemin packed : ", file_path, "; room south : ", room_generator.room_South.size())
			Utils.ORIENTATION.EAST:
				if !room_generator.room_East.has(load(file_path)):
					room_generator.room_East.push_back(load(file_path))
					print("Chemin packed : ", file_path, "; room east : ", room_generator.room_East.size())
			Utils.ORIENTATION.WEST:
				if !room_generator.room_West.has(load(file_path)):
					room_generator.room_West.push_back(load(file_path))
					print("Chemin packed : ", file_path, "; room west : ", room_generator.room_West.size())
	
	print("----- next room -----")
	queue_free()

func generate_room() -> void:
	if room_generator.Instance.has_end_generation:
		print("-------------- End GEN ----------------")
		return

	var world_bound = get_world_bounds()
	# Salles qui seront ajouté au Node à la fin de la fonction
	var rooms : Array

	for door in doors:
		
		var index = 0
		var can_be_generated = false

		if door.orientation == origin:
			continue

		# Tant que l'on a pas trouvé une salle spawnable, on continue d'essayer autant de fois qu'il y a de salle dans la liste des salles disponible
		# Sinon, on applique l'état Wall à la porte 
		while(!can_be_generated):
			var packed_scene = room_generator.Instance.get_opposite_room_from_orientation(door.orientation)
			if packed_scene != null:
				var room_instantiate = packed_scene.instantiate()

				match door.orientation:
					Utils.ORIENTATION.NORTH:
						#print("-- North --")
						if can_add_room_north:
							room_instantiate.position = position
							room_instantiate.position -= Vector2(0, world_bound.size.y)
							room_instantiate.room_pos = room_pos + Vector2i(0, room_size.y)
							room_instantiate.origin = Utils.ORIENTATION.SOUTH
					Utils.ORIENTATION.SOUTH:
						#print("-- South --")
						if can_add_room_south:
							room_instantiate.position = position
							room_instantiate.position += Vector2(0, world_bound.size.y)
							room_instantiate.room_pos = room_pos + Vector2i(0, -room_size.y)
							room_instantiate.origin = Utils.ORIENTATION.NORTH
					Utils.ORIENTATION.EAST:
						#print("-- East --")
						if can_add_room_east:
							room_instantiate.position = position
							room_instantiate.position += Vector2(world_bound.size.x, 0)
							room_instantiate.room_pos = room_pos + Vector2i(room_size.x, 0)
							room_instantiate.origin = Utils.ORIENTATION.WEST
					Utils.ORIENTATION.WEST:
						#print("-- West --")
						if can_add_room_west:
							room_instantiate.position = position
							room_instantiate.position -= Vector2(world_bound.size.x, 0)
							room_instantiate.room_pos = room_pos + Vector2i(-room_size.x, 0)
							room_instantiate.origin = Utils.ORIENTATION.EAST

				if room_instantiate != null:
					can_be_generated = check_for_valid_room(room_instantiate) && check_generation_size(room_instantiate, door.orientation)

					if can_be_generated:	
						room_instantiate.is_generated = true;
						rooms.push_back(room_instantiate)
				else:
					print("Room instantiate is null")
				
				index += 1
				if index >= room_generator.get_opposite_roomlist_size_from_orientation(door.orientation) && !can_be_generated:
					door.set_state(Door.STATE.WALL)
					can_be_generated = true

	for room in rooms:
		room_generator.Instance.room_node.add_child(room)
		
	rooms.clear()

func spawn_enemy() -> void:
	var random_index = random.randi_range(0,1)
	var packedEnemy : PackedScene

	if random_index == 0:
		packedEnemy = room_generator.get_random_priority_enemy()
	
	if packedEnemy == null:
		packedEnemy = room_generator.get_random_enemy()

	for spawnpoint in spawnpoints:
		var enemy_instantiate = packedEnemy.instantiate()
		var room_bounds = get_world_bounds()
		enemy_instantiate.position = Vector2(room_bounds.position.x + spawnpoint.position.x, room_bounds.position.y - spawnpoint.position.y)
		room_generator.enemy_node.add_child(enemy_instantiate)
	
# Verifie si la salle entre en collision avec un autre Rect2 de salle
func check_for_valid_room(room_instantiate : Room) -> bool:
	for room in all_rooms:
		if room.get_world_bounds().intersects(room_instantiate.get_world_bounds()) && room != room_instantiate:
			return false
		
	return true
	
# Verifie si l'on a atteint la taille maximale de la map
func check_generation_size(room_instantiate : Room, orientation : Utils.ORIENTATION) -> bool:
	var pos = room_instantiate.room_pos
	var max_size = room_generator.Instance.map_size

	var max_X_reached = pos.x >= max_size.x
	var min_X_reached = pos.x <= -max_size.x
	var max_Y_reached = pos.y >= max_size.y
	var min_Y_reached = pos.y <= -max_size.y

	match orientation:
		Utils.ORIENTATION.NORTH:
			if max_Y_reached:
				can_add_room_north = false
				return false
		Utils.ORIENTATION.SOUTH:
			if min_Y_reached:
				can_add_room_south = false
				return false
		Utils.ORIENTATION.EAST:
			if max_X_reached:
				can_add_room_east = false
				return false
		Utils.ORIENTATION.WEST:
			if min_X_reached:
				can_add_room_west = false
				return false

	var mapSizeReached = (max_X_reached || min_X_reached) && (max_Y_reached || min_Y_reached)
	if mapSizeReached:
		room_generator.Instance.has_end_generation = true
		return false
	
	return true


func get_local_bounds() -> Rect2:
	var room_bounds = Rect2()
	if tilemap_layers == null || tilemap_layers.size() == 0:
		return room_bounds
	## Encapsulate all tilemap_layers
	for tilemap in tilemap_layers:
		var bounds = tilemap.get_used_rect() # Gives rect in nb of tiles not pixels
		var size_pixel = tilemap.tile_set.tile_size
		bounds.position = Vector2i(bounds.position.x * size_pixel.x, bounds.position.y * size_pixel.y)
		bounds.size = Vector2i(bounds.size.x * size_pixel.x, bounds.size.y * size_pixel.y)
		room_bounds = room_bounds.merge(bounds)
	return room_bounds


func get_world_bounds() -> Rect2:
	var result = get_local_bounds()
	result.position += position
	return result


func contains(point: Vector2) -> bool:
	var bounds = get_world_bounds()
	return bounds.has_point(point)


func on_enter_room(from: Room) -> void:
	var camera_bounds = get_world_bounds()
	_cam.set_bounds(camera_bounds)


func get_adjacent_room(orientation: Utils.ORIENTATION, from: Vector2) -> Room:
	var dir: Vector2i = Utils.OrientationToDir(orientation)
	var adjacent_pos: Vector2i = room_pos + dir + get_position_offset(from)

	for room in all_rooms:
		if is_room_adjacent(room, adjacent_pos):
			return room
			
	return null


func is_room_adjacent(room: Room, adjacent_pos: Vector2) -> bool:
	return (
		adjacent_pos.x >= room.room_pos.x
		&& adjacent_pos.y >= room.room_pos.y
		&& adjacent_pos.x < room.room_pos.x + room.room_size.x
		&& adjacent_pos.y < room.room_pos.y + room.room_size.y
	)


func get_door(orientation: Utils.ORIENTATION, from: Vector2) -> Door:
	var door_position: Vector2i = Vector2i(position) + get_position_offset(from)
	for door in doors:
		var offsetPos = Vector2i(position) + get_position_offset(door.position)
		print(door.orientation, " ; ", orientation)
		print(door_position == offsetPos, " ; ", door.orientation == orientation)
		if door_position == offsetPos && door.orientation == orientation:
			return door
	return null


func get_position_offset(world_point: Vector2) -> Vector2i:
	if room_size.x <= 1 && room_size.y <= 1:
		return Vector2i.ZERO

	var offset: Vector2i = Vector2i.ZERO

	if room_size.y > 1:
		offset.y = room_size.y - 1
	return offset

func get_center_from_room() -> Vector2:
	var world_bound = get_world_bounds()
	return Vector2(world_bound.size.x / 2, -world_bound.size.y / 2)

func _exit_tree() -> void:
	all_rooms.erase(self)
