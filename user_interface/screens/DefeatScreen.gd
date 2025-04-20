extends Node
class_name DefeatScreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_button_pressed() -> void:
	GameInstance.RestartCurrentLevel()

func _on_menu_button_pressed() -> void:
	GameInstance.TravelToMenu()
