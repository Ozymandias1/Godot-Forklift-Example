extends CharacterBody3D

const SPEED = 5.0
const BASE_SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_3d = $CameraPivot/Camera3D
@onready var animation_tree = $"3DGodotRobot/AnimationTree"
@onready var boarding_label = $Boarding_Label
@onready var body_collision = $BodyCollision
@onready var body_mesh = $"3DGodotRobot"

var original_parent: Node3D = null
var entered_vehicle = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var vehicle_list: Array[Node3D] = []

# 스크립트 시작
func _ready():
	original_parent = self.get_parent_node_3d()
	camera_3d.make_current()

# 물리 업데이트
func _physics_process(delta):		
	# 차량 탑승/하차
	if Input.is_action_just_pressed("Use"):
		if entered_vehicle == null:
			_enter_vehicle()
		else:
			_exit_vehicle()
	
	# 차량 탑승시에는 뷰전환외에 다른 조작을 하지 않음
	if entered_vehicle != null:
		if Input.is_action_just_pressed("Change View"):
			_change_view()
		return
			
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

# 점프/추락 애니메이션 처리
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

# 탑승 가능한 탈것 목록에서 제거
func remove_available_vehicle(vehicle: Node3D):
	vehicle_list.erase(vehicle)
	update_boarding_label_visible()

# 탑승 표시 텍스트 가시화 상태 처리
func update_boarding_label_visible():
	boarding_label.visible = vehicle_list.size() > 0

# 캐릭터 몸체 충돌 비활성화
func _disable_collision():
	body_collision.disabled = true

# 캐릭터 몸체 충돌 활성화
func _enable_collision():
	body_collision.disabled = false

# 탑승시 캐릭터 애니메이션을 대기 상태로 만든다
func _set_animation_to_idle():
	animation_tree.play_locomotion()
	animation_tree["parameters/Locomotion/blend_position"] = 0.0

# 탑승 처리
func _enter_vehicle():
	if vehicle_list.is_empty():
		return
	
	# 탑승 가능한 기체가 있는 경우만
	entered_vehicle = vehicle_list[0]
		
	reparent(entered_vehicle, true)
	position = entered_vehicle.drive_location.position
	rotation = entered_vehicle.drive_location.rotation
	_disable_collision()
	
	entered_vehicle.is_controllable = true
	_set_animation_to_idle()

# 하차 처리
func _exit_vehicle():
	if entered_vehicle == null:
		return
	
	entered_vehicle.is_controllable = false
	
	# 차량에 탑승한 상태에서만
	reparent(original_parent, true)
	global_position = entered_vehicle.exit_location.global_position
	global_rotation = entered_vehicle.exit_location.global_rotation
	_enable_collision()
	
	entered_vehicle = null

# 뷰 전환
func _change_view():
	if camera_3d.current:
		body_mesh.visible = false # 1인칭 뷰에서는 캐릭터 메시를 숨긴다
		entered_vehicle.fps_camera.make_current()
	else:
		body_mesh.visible = true
		camera_3d.make_current()
