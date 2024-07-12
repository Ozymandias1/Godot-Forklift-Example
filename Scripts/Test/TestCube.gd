extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_x(1.0 * delta)
	rotate_y(2.0 * delta)
	rotate_z(3.0 * delta)
