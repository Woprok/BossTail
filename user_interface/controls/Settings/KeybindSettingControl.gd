extends Panel
class_name KeybindSettingControl

var is_changing_binding: bool = false
var action_name_binding: StringName = ""
var current_binded_keys: Array[InputEvent] = []
var latest_event: InputEvent = null

func AsKeybindSetting() -> KeybindSetting:
	var ks = KeybindSetting.new()
	ks.action_name = action_name_binding
	ks.inputs = current_binded_keys
	return ks

func Apply() -> void:
	if latest_event:
		InputMap.action_erase_events(action_name_binding)
		InputMap.action_add_event(action_name_binding, latest_event)
		current_binded_keys.clear()
		current_binded_keys.append(latest_event)

func set_keybind(action_name: StringName, binded_keys: Array[InputEvent], readable_name: String) -> void:
	%NameLabel.text = readable_name
	current_binded_keys = binded_keys
	%KeyLabel.text = get_binded(current_binded_keys)
	action_name_binding = action_name

func get_binded(binded_keys: Array[InputEvent]) -> String:
	var text_representation: String = ""
	for binding in binded_keys:
		if text_representation.length() > 0:
			text_representation += '; '
		text_representation += binding.as_text()
	
	return text_representation

func _input(event: InputEvent) -> void:
	if not is_changing_binding:
		return
	if not event is InputEventMouseButton and not event is InputEventKey:
		return
	
	is_changing_binding = false
	latest_event = event
	_refresh_binding()
	accept_event()
	
func _refresh_binding() -> void:
	if latest_event:
		%KeyLabel.text = latest_event.as_text()
	else:
		%KeyLabel.text = get_binded(current_binded_keys)

func _on_change_button_pressed() -> void:
	is_changing_binding = true
