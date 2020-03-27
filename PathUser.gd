extends RigidBody2D

const FIELD_STRENGTH = 1000

var path_field := {}
var dimensions = Vector2()

func _ready() -> void:
	linear_velocity = Vector2(0, 200).rotated(rand_range(0, 2*PI))

func _process(_delta : float) -> void:
	path_field = get_parent().path_field
	dimensions = get_parent().dimensions

func _physics_process(_delta : float) -> void:
	# Convert screen pos to grid pos
	var grid_pos : Vector2 = (position / OS.window_size * dimensions).floor()
	if path_field.has(grid_pos):
		applied_force = path_field[grid_pos].vector * FIELD_STRENGTH
	else:
		applied_force = Vector2.ZERO

func _on_Timer_timeout() -> void:
	queue_free()
