extends Node
class_name InputUtils

static var font_size_start_tag: String = '[font_size=64]'
static var font_size_end_tag: String = '[/font_size]'
static var font_start_tag: String = '[font="res://user_interface/input_prompts/kenney_input_svg.ttf"]' 
static var font_end_tag: String = '[/font]'

static func Convert(data: TutorialDataModel, text: String) -> String:
	var converted_text = text
	for key in data.TutorialActions.keys():
		converted_text = _replace_by(converted_text, key, data.TutorialActions.get(key))
	return converted_text

# in text replace all symbols with equivalent of action in specific font
static func _replace_by(text: String, symbol: String, action: String) -> String:
	var value: String = ""
	
	if text.contains(symbol):
		value = _get_action_as_text(action)
		return text.replace(symbol, value)
	return text

static func _get_action_as_text(action: String) -> String:
	var actions: Array[InputEvent] = InputMap.action_get_events(action)
	print(actions)
	var stringified_action: String = ""
	
	for mapping: InputEvent in actions:
		if mapping is InputEventKey:
			var key_action: InputEventKey = mapping as InputEventKey
			if InputDatabase.key_to_name.has(key_action.physical_keycode):
				stringified_action += font_start_tag + font_size_start_tag
				stringified_action += InputDatabase.unified_dictionary.get(InputDatabase.key_to_name.get(key_action.physical_keycode)) 
				stringified_action += font_size_end_tag + font_end_tag
			
		if mapping is InputEventMouseButton:
			var mouse_action: InputEventMouseButton = mapping as InputEventMouseButton
			if InputDatabase.mouse_to_name.has(mouse_action.button_index):
				stringified_action += font_start_tag + font_size_start_tag
				stringified_action += InputDatabase.unified_dictionary.get(InputDatabase.mouse_to_name.get(mouse_action.button_index))
				stringified_action += font_size_end_tag + font_end_tag
	
	return stringified_action
