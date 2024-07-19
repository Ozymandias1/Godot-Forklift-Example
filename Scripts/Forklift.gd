extends VehicleBody3D

@onready var wheel_fl = $Wheel_FL
@onready var wheel_fr = $Wheel_FR

var max_rpm = 300
var max_torque = 100

func _physics_process(delta):
	steering = lerp(steering, Input.get_axis("Steer Left", "Steer Right") * 0.5, 5 * delta)
	
	var acceleration = Input.get_axis("Brake", "Throttle")
	var rpm = wheel_fl.get_rpm()
	wheel_fl.engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = wheel_fr.get_rpm()
	wheel_fr.engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
