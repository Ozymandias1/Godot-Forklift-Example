extends VehicleBody3D

@onready var wheel_fl = $Wheel_FL
@onready var wheel_fr = $Wheel_FR
@onready var drive_location = $DriveLocation
@onready var exit_location = $ExitLocation
@onready var fork = $Body/Mast/Fork
@onready var mast = $Body/Mast
@onready var steer_mesh = $Body/Steer
@onready var lever_height = $"Body/Lever-Height"
@onready var lever_tilt = $"Body/Lever-Tilt"
@onready var fps_camera = $FPSCamera
@onready var engine_sfx = $EngineSFX
@onready var lift_sfx = $LiftSFX

var max_rpm = 300
var max_torque = 100

var is_controllable = false
var lever_height_input: float = 0.0
var lever_tilt_input: float = 0.0

var min_velocity_length: float = 0.0
var max_velocity_length: float = 5.0

func _ready():
	lift_sfx.stream_paused = true

func _physics_process(delta):
	_handle_engine_sfx()
	
	if not is_controllable:
		return

	steering = lerp(steering, Input.get_axis("Steer Left", "Steer Right") * 0.5, 5 * delta)

	var acceleration = Input.get_axis("Brake", "Throttle")
	var rpm = wheel_fl.get_rpm()
	wheel_fl.engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = wheel_fr.get_rpm()
	wheel_fr.engine_force = acceleration * max_torque * (1 - rpm / max_rpm)

	_handle_lift_control(delta)
	_handle_steering_and_lever_animation(delta)

# 리프트 조작 처리
func _handle_lift_control(delta: float):
	# 상하 이동
	if Input.is_action_pressed("Lift Up"):
		fork.position.y += 1.0 * delta
	if Input.is_action_pressed("Lift Down"):
		fork.position.y -= 1.0 * delta

	# 앞뒤 틸트
	if Input.is_action_pressed("Lift Tilt Front"):
		mast.rotation.x += 0.25 * delta
	if Input.is_action_pressed("Lift Tilt Back"):
		mast.rotation.x -= 0.25 * delta

	fork.position.y = clampf(fork.position.y, -0.203, 1.878)
	mast.rotation.x = clampf(mast.rotation.x, deg_to_rad(-8.0), 0.0)
	
	if Input.is_action_pressed("Lift Up") or Input.is_action_pressed("Lift Down") or Input.is_action_pressed("Lift Tilt Front") or Input.is_action_pressed("Lift Tilt Back"):
		lift_sfx.stream_paused = false
	else:
		lift_sfx.stream_paused = true

# 스티어링/레버 조작 애니메이션 처리
func _handle_steering_and_lever_animation(delta: float) -> void:
	steer_mesh.rotation.y = -steering * 2.5
	
	lever_height_input = lerp(lever_height_input, Input.get_axis("Lift Down", "Lift Up") * deg_to_rad(7.0), 5 * delta)
	lever_height.rotation.x = deg_to_rad(-14.8) + lever_height_input
	
	lever_tilt_input = lerp(lever_tilt_input, Input.get_axis("Lift Tilt Back", "Lift Tilt Front") * deg_to_rad(7.0), 5 * delta)
	lever_tilt.rotation.x = deg_to_rad(-14.8) + lever_tilt_input

# 차량 엔진 사운드 효과 처리
func _handle_engine_sfx():	
	var velocity_length = clamp(linear_velocity.length(), 0.0, 5.0)
	var velocity_ratio = inverse_lerp(0.0, 5.0, velocity_length)
	var pitch_result = 1.0 + velocity_ratio
	engine_sfx.pitch_scale = pitch_result

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
