extends AnimationPlayer

func _ready() -> void:
	UIManager.SwitchToMode(UI.Mode.NONE)
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = false
	get_parent().get_node("Player").disable_controls()
	
	play("intro")
	await animation_finished
	get_parent().get_node("frog").handle_bubble_spit(6)
	
	UIManager.SwitchToMode(UI.Mode.HUD)
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = true
	get_parent().get_node("Player").enable_controls()
	
