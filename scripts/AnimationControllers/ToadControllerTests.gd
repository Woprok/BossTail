extends Node3D

@export var toad_controller : ToadAnimationController
var swipe_indic: ToadAtkIndicatorVFXController
@export var swipeIndicScene: PackedScene
@export var toad: Frog
@export var toadDeathVFX: DeathVFX
@export var hitVFX: EntityHitVFX
@export var impactVFX: PackedScene
@export var impactPos: Node3D

func _ready() -> void:
	#toad_controller.swim_bubble_atk_start(1,0)
	#create_tween().tween_callback(test_impact).set_delay(2.9)
	#create_tween().tween_callback(hitVFX.play_effect).set_delay(3)
	create_tween().tween_callback(toadDeathVFX.play_effect).set_delay(1.5)
	pass

func test_impact():
	var impactObj: Node3D = impactVFX.instantiate()
	self.add_child(impactObj)
	impactObj.global_position = impactPos.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("move_forward"):
		toad_controller.swipe_start(1, 0.5)
		
		toad.rotate_y(PI)
		
		if !swipe_indic:
			swipe_indic = toad.instantiate_indicator_object(toad.swipe_indicator, Vector3.ZERO)
			
			swipe_indic.appear(0.7)
			get_tree().create_tween().tween_callback(swipe_indic.fade.bind(0.5)).set_delay(1)
			#toad_controller.OnAttackStarted.connect(swipe_indic.fade.bind(1))
		
	if event.is_action_released("move_back"):
		toad_controller.ground_slam_start(1, 0)
	if event.is_action_released("move_left"):
		toad_controller.tongue_grab_start(1,0)
	if event.is_action_released("move_right"):
		toad_controller.spit_start(1.5, 0.5)
		
