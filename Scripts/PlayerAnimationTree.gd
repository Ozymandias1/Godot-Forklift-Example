extends AnimationTree

enum {
	LOCOMOTION,
	JUMPING,
	FALL
}

var state

func _ready():
	state = LOCOMOTION

func select_random_jump_anim():
	self["parameters/Jumping/blend_position"] = randi_range(0, 1)

func play_jump_animation():
	state = JUMPING

func play_fall_animation():
	state = FALL
	
func play_locomotion():
	state = LOCOMOTION
