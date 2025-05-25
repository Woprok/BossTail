extends Resource
class_name LocalUserSettings

# Mouse with some clamping to be sure its valid value
const default_mouse_aim_sensititivy: float = 1.0
const default_mouse_camera_sensititivy: float = 1.0
@export var _mouse_aim_sensitivity: float = 1.0
@export var _mouse_camera_sensitivity: float = 1.0
var mouse_aim_sensititivy: float:
	set(value):
		_mouse_aim_sensitivity = clamp(value, 0.01, 2.0)
	get:
		return _mouse_aim_sensitivity
var mouse_camera_sensititivy: float:
	set(value):
		_mouse_camera_sensitivity = clamp(value, 0.01, 2.0)
	get:
		return _mouse_camera_sensitivity
# Window
const default_is_full_screen: bool = false
@export var is_full_screen: bool = false
# Keybinds
@export var custom_keybinds: Dictionary[StringName, KeybindSetting] = {}

func ResetValues() -> void:
	# Mouse
	mouse_aim_sensititivy = default_mouse_aim_sensititivy
	mouse_camera_sensititivy = default_mouse_camera_sensititivy
	# Window
	is_full_screen = default_is_full_screen

func ResetKeybinds() -> void:
	custom_keybinds.clear()

func AddKeybind(keybinds: KeybindSetting):
	custom_keybinds.set(keybinds.action_name, keybinds)

func HasKeybind(action_name:StringName) -> bool:
	return custom_keybinds.has(action_name)

func GetKeybind(action_name: StringName) -> Array[InputEvent]:
	return custom_keybinds.get(action_name).inputs
