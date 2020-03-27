extends Button

func _process(delta) -> void:
	update()

func _draw() -> void:
	var data : Dictionary = get_parent().path_field
	var dimensions : Vector2 = get_parent().dimensions
	
	for coord in data:
		var screen_pos : Vector2 = coord / dimensions * OS.window_size
		var screen_size := OS.window_size / dimensions
		var screen_pos_center := screen_pos + screen_size / 2.0
		draw_rect(Rect2(screen_pos, screen_size), Color(data[coord].distance / dimensions.length(), 0, 0))
		draw_line(screen_pos_center, screen_pos_center + data[coord].vector * screen_size / 2.1, Color.white)
