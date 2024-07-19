extends CharacterBody3D


const SPEED = 5.0
const BASE_SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_3d = $CameraPivot/Camera3D
@onready var animation_tree = $"3DGodotRobot/AnimationTree"
@onready var boarding_label = $Boarding_Label

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var vehicle_list: Array[Node3D] = []

# 스크립트 시작
func _ready():
	camera_3d.make_current()

# 물리 업데이트
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		animation_tree.select_random_jump_anim()
		velocity.y = JUMP_VELOCITY

	_handle_jump_fall_animation()
	_handle_movement(delta)
	move_and_slide()

# 기본 이동
func _handle_movement(delta):
	var input_dir = Input.get_vector("Move Left", "Move Right", "Move Down", "Move Up")
	var ground_plane = Plane(Vector3.UP)
	var horizontal_movement_input = camera_3d.global_basis.x * input_dir.x
	var vertical_movement_input = ground_plane.project(camera_3d.global_basis.y) * input_dir.y

	var desire_direction = (horizontal_movement_input + vertical_movement_input).normalized()

	if desire_direction:
		velocity.x = desire_direction.x * SPEED
		velocity.z = desire_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 이동 애니메이션
	var dirLen = desire_direction.length()
	animation_tree["parameters/Locomotion/blend_position"] = lerp(animation_tree["parameters/Locomotion/blend_position"], dirLen * (SPEED / BASE_SPEED), 5.0 * delta)

	# 입력 방향에 따른 회전 처리
	if desire_direction:
		var target_transform = transform.looking_at(global_position + desire_direction, Vector3.UP, true)
		transform = transform.interpolate_with(target_transform, 10.0 * delta)

func _handle_jump_fall_animation():
	if is_on_floor():
		animation_tree.play_locomotion()
	else:
		var is_falling = get_position_delta().y < 0.0
		if is_falling:
			animation_tree.play_fall_animation()
		else:
			animation_tree.play_jump_animation()

# 탑승 가능한 탈것 목록에 추가
func add_available_vehicle(vehicle: Node3D):
	vehicle_list.append(vehicle)
	update_boarding_label_visible()

func remove_available_vehicle(vehicle: Node3D):
	vehicle_list.erase(vehicle)
	update_boarding_label_visible()

func update_boarding_label_visible():
	boarding_label.visible = vehicle_list.size() > 0
