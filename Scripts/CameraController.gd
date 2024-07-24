extends Node3D

@onready var camera_3d = $Camera3D

@export var follow_target: Node3D
@export var cam_height: float = 1.325

var camera_local_pos_target: Vector3

# 시작
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_local_pos_target = camera_3d.position

# 업데이트
func _process(delta):
	# 위치 업데이트
	if follow_target:
		self.global_position = follow_target.global_position + (Vector3.UP * cam_height)
	
	camera_3d.position = lerp(camera_3d.position, camera_local_pos_target, 5.0 * delta)
	
	# 지게차 탑승 하차시 roll값이 변경되는 경우가 있으므로 0.0으로 고정시킨다.
	rotation.z = 0.0

# 입력 처리
func _input(event):
	if event.is_action_pressed("Show Cursor"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		
	if event.is_action("Zoom In"):
		camera_local_pos_target.z -= 1.0
	if event.is_action("Zoom Out"):
		camera_local_pos_target.z += 1.0
			
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		global_rotate(Vector3.UP, event.relative.x * -0.001)
		global_rotate(camera_3d.global_transform.basis.x, event.relative.y * -0.001)
