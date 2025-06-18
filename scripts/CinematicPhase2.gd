extends AnimationPlayer

func _ready() -> void:
	UIManager.SwitchToMode(UI.Mode.NONE)
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = false
	get_parent().get_node("Player").disable_controls()
	
	play("intro")

	await animation_finished
	get_parent().get_node("frog").boss_data.boss_restart()
	get_parent().get_node("frog").plan_path(get_parent().get_node("stonePlatforms/stonePlatform2"))
	
	UIManager.SwitchToMode(UI.Mode.HUD)
	get_parent().get_node("Camera3D").current = false
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = true
	get_parent().get_node("Player").enable_controls()
	
