extends Node
class_name SettingsScreen

@export var default_user_settings: UserSettings = preload("res://data_resources/UserSettingsDefaultInstance.tres")

func _ready() -> void:
	# setup the keybind list
	%KeybindList.LoadListFrom(default_user_settings)

func _on_back_button_pressed() -> void:
	UIManager.SwitchToPrevious()

func _on_save_button_pressed() -> void:
	var local: LocalUserSettings = default_user_settings.GetUserSettings()
	%KeybindList.ApplyList()
	%KeybindList.SaveListTo(local)
	default_user_settings.SaveUserSettings(local)
	UIManager.SwitchToPrevious()

func _on_reset_button_pressed() -> void:
	# Reset keybinds to default
	InputMap.load_from_project_settings()
	var local: LocalUserSettings = default_user_settings.GetUserSettings()
	local.ResetKeybinds()
	default_user_settings.SaveUserSettings(local)	
	# HARD RESET OF UI
	%KeybindList.ClearList()
	%KeybindList.LoadListFrom(default_user_settings)
