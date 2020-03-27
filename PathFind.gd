extends Node

export var dimensions := Vector2(30, 30)

var goals := [Vector2(10, 10)]
var walls := [Rect2(10,10,3,10), Rect2(10, 20, 20, 3)]

var temp_node_coords := []
var path_field := {}

func _ready() -> void:
	for wall in walls:
		wall.position = wall.position / dimensions * OS.window_size
		wall.size = wall.size / dimensions * OS.window_size
		
		var shape := RectangleShape2D.new()
		shape.extents = wall.size / 2.0
		var shape_id : int = $Walls.create_shape_owner($Walls)
		$Walls.shape_owner_add_shape(shape_id, shape)
		$Walls.shape_owner_set_transform(shape_id, Transform2D().translated(Vector2(wall.position + wall.size/2.0)))
#		$Walls.add_child(collision)

func _on_Grid_pressed() -> void:
	var goal_pos = (get_viewport().get_mouse_position() / OS.get_window_size().x * dimensions).floor()
	goals = [goal_pos, goal_pos + Vector2.RIGHT, goal_pos + Vector2.DOWN, goal_pos + Vector2.ONE]
	update()

func _process(_delta : float) -> void:
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		var path_user := preload("res://PathUser.tscn").instance()
		path_user.position = get_viewport().get_mouse_position()
		add_child(path_user)

func update() -> void:
	# Clear any previous data
	path_field.clear()
	temp_node_coords = goals.duplicate()
	
	# Stop when there are no more nodes to travel from.
	var distance = 0
	while not temp_node_coords.empty():
		var temp_node_coords_buffer := []
		
		for coord in temp_node_coords:
			path_field[coord] = {distance=distance, vector=Vector2.ZERO}
			
			# For each neighboring node...
			var offsets := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
			for offset in offsets:
				var child = coord + offset
				
				# Check if potenial node would be out of bounds...
				if child.x > dimensions.x-1 or child.x < 0 or child.y > dimensions.y-1 or child.y < 0:
					continue
				# or if the path field or coord buffer already has it...
				if path_field.has(child) or temp_node_coords_buffer.has(child):
					continue
				# or if there's a wall.
				var inside_wall = false
				for wall in walls:
					if wall.has_point(child):
						inside_wall = true
						break
				if inside_wall:
					continue
				
				# If not, add it to buffer...
				temp_node_coords_buffer.append(child)
		
		# And swap buffer with current nodes to travel
		temp_node_coords = temp_node_coords_buffer
		distance += 1
	
	# Calculate vectors for each node.
	for coord in path_field:
		var neighbor_dists := []
		for offset in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			if path_field.has(coord + offset):
				neighbor_dists.append(path_field[coord + offset].distance) 
			else:
				neighbor_dists.append(path_field[coord].distance)
		
		var vector := Vector2(
				neighbor_dists[0] - neighbor_dists[1],
				neighbor_dists[2] - neighbor_dists[3]
		).normalized()
		path_field[coord].vector = vector
