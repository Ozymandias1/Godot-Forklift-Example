extends VehicleBody3D

@onready var wheel_fl = $Wheel_FL
@onready var wheel_fr = $Wheel_FR

var max_rpm = 300
var max_torque = 100

var is_controllable = false

func _physics_process(delta):
	if not is_controllable:
		return
	
	steering = lerp(steering, Input.get_axis("Steer Left", "Steer Right") * 0.5, 5 * delta)
	
	var acceleration = Input.get_axis("Brake", "Throttle")
	var rpm = wheel_fl.get_rpm()
	wheel_fl.engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = wheel_fr.get_rpm()
	wheel_fr.engine_force = acceleration * max_torque * (1 - rpm / max_rpm)

# 탑승구역(BoardingArea)에 뭔가 탐지되었을 경우 처리
func _on_boarding_area_body_entered(body):
	if body.get_meta("is_player", false):
		var player = body
		player.add_available_vehicle(self)

# 탑승구역(BoardingArea)에서 탐지된 객체가 빠져나갈 경우 처리
func _on_boarding_area_body_exited(body):
	if body.get_meta("is_player", false):
		var player = body
		player.remove_available_vehicle(self)
