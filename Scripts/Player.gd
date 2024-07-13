extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_3d = $CameraPivot/Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# 스크립트 시작
func _ready():
	camera_3d.make_current()

# 물리 업데이트
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
