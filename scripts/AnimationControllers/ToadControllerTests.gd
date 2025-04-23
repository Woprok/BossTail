extends Node3D

@export var toad_controller : ToadAnimationController

func _ready() -> void:
	toad_controller.swim_bubble_atk_start(1,0)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("move_forward"):
		toad_controller.swipe_start(1, 0)
	if event.is_action_released("move_back"):
		toad_controller.ground_slam_start(1, 0)
	if event.is_action_released("move_left"):
		toad_controller.tongue_grab_start(1,0)
	if event.is_action_released("move_right"):
		toad_controller.spit_start(1.5, 0.5)
		
