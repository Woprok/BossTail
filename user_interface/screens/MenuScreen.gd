extends Node
class_name MenuScreen

func _on_play_button_pressed() -> void:
	UIManager.SwitchToLevel()

func _on_settings_button_pressed() -> void:
	UIManager.SwitchToSettings()

func _on_quit_button_pressed() -> void:
	GameInstance.Quit()
