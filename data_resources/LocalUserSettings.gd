extends Resource
class_name LocalUserSettings

@export var custom_keybinds: Dictionary[StringName, KeybindSetting] = {}

func ResetKeybinds() -> void:
	custom_keybinds.clear()

func AddKeybind(keybinds: KeybindSetting):
	custom_keybinds.set(keybinds.action_name, keybinds)

func HasKeybind(action_name:StringName) -> bool:
	return custom_keybinds.has(action_name)

func GetKeybind(action_name: StringName) -> Array[InputEvent]:
	return custom_keybinds.get(action_name).inputs
