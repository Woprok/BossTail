extends Node
class_name PauseScreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_button_pressed() -> void:
	GameInstance.ResumeGame()

func _on_menu_button_pressed() -> void:
	GameInstance.TravelToMenu()
