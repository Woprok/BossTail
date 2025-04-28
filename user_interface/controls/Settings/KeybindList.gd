extends VBoxContainer
class_name KeybindList

@onready var keysetting_class = preload("res://user_interface/controls/Settings/KeybindSettingControl.tscn")

var keybind_list: Array[KeybindSettingControl] = []

func ClearList() -> void:
	# Fast cleanup, this is recreatd anyway each time settings are opened
	# should be improved if we ever make UI persist
	keybind_list.clear()
	for child in get_children():
		child.queue_free()

func LoadListFrom(user_settings: UserSettings) -> void:
	var predefined_actions: Array[StringName] = InputMap.get_actions()
	for action_name: StringName in predefined_actions: 
		if not user_settings.customizable_keybinds.has(action_name):
			continue
		var binded_keys: Array[InputEvent] = InputMap.action_get_events(action_name)
		var next_bind: KeybindSettingControl = keysetting_class.instantiate()
		next_bind.set_keybind(action_name, binded_keys, user_settings.customizable_keybinds[action_name])
		keybind_list.append(next_bind)
		add_child(next_bind)

func ApplyList() -> void:
	for keybind: KeybindSettingControl in keybind_list:
		keybind.Apply()

func SaveListTo(local_user_settings: LocalUserSettings) -> void:
	for keybind: KeybindSettingControl in keybind_list:
		local_user_settings.AddKeybind(keybind.AsKeybindSetting())
