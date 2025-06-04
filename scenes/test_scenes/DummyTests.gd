extends Node3D

@export var DummyAnimCtrlr: BigDummyAnimController
@export var DummyEntityNode: Node3D
@export var SlashVFX: PackedScene
@export var Whirlwind: WhirlwindVFXController

func _ready():
	#create_tween().set_loops(-1).tween_callback(slash_test).set_delay(1.25)
	create_tween().set_loops(-1).tween_callback(whirlwind_test).set_delay(2.5)
	#slash_test()
	pass

func whirlwind_test():
	DummyAnimCtrlr.whirlwind_start(1.5)
	Whirlwind.appear_whirlwind(1)
	create_tween().tween_callback(do_whirlwind_shockwave).set_delay(1.65)
	
func do_whirlwind_shockwave():
	Whirlwind.shockwave()
	Whirlwind.fade_whirlwind(0.15)

func slash_test():
	DummyAnimCtrlr.great_slash_start(0.5)
	create_tween().tween_callback(spawn_slash_vfx).set_delay(0.5)
	
func spawn_slash_vfx():
	var slash_vfx_node: Node3D = SlashVFX.instantiate()
	DummyEntityNode.add_child(slash_vfx_node)
	#slash_vfx_node.rotation = DummyEntityNode.rotation
	
	
