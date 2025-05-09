extends PanelContainer
class_name TutorialHint

func SetData(tutorial_data: TutorialDataModel, phase: int) -> void:
	_set_objective(		InputUtils.Convert(tutorial_data, tutorial_data.Objectives.get(phase)))
	_set_flavor(		InputUtils.Convert(tutorial_data, tutorial_data.ObjectiveFlavors.get(phase)))
	_set_control_title(	InputUtils.Convert(tutorial_data, tutorial_data.ControlHintTitles.get(phase)))
	_set_control_hint(	InputUtils.Convert(tutorial_data, tutorial_data.ControlHints.get(phase)))

func _set_objective(context: String) -> void:
	%ObjectiveLabel.text = context
	
func _set_flavor(context: String) -> void:
	%ObjectiveFlavor.text = context
	
func _set_control_title(context: String) -> void:
	%HintLabel.text = context
	
func _set_control_hint(context: String) -> void:
	%HintDescription.text = context
