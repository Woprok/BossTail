extends AnimationPlayer
@export var platform:Node

func _ready() -> void:
	GameInstance.connect("level_end", LevelEnd)
	
	UIManager.SwitchToMode(UI.Mode.NONE)
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = false
	get_parent().get_node("Player").disable_controls()
	
	play("intro")
	await animation_finished
	get_parent().get_node("frog").handle_bubble_spit(6)
	
	UIManager.SwitchToMode(UI.Mode.HUD)
	get_parent().get_node("Camera3D").current = false
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = true
	get_parent().get_node("Player").enable_controls()
	
func LevelEnd():
	UIManager.SwitchToMode(UI.Mode.NONE)
	
	get_parent().get_node("frog").plan_path(platform) 
	#waiting for frog on center platform
	while get_parent().get_node("frog").platform!=platform:
		await get_tree().create_timer(0.1).timeout
		
	#jump to water
	get_parent().get_node("frog").jump_direction(Vector3(38.84,-0.134,-25.258))
	await get_tree().create_timer(1).timeout
	
	get_parent().get_node("frog").cinematic = true
	get_parent().get_node("Player").get_node("CameraPivot/SpringArm3D/Camera3D").current = false
	get_parent().get_node("Player").disable_controls()
	get_parent().get_node("Camera3D").current = true
	
	play("end")
	
	await animation_finished
	GameInstance.TravelToNextLevel()
