extends PanelContainer
class_name TutorialHint

var piktogram_edition: bool = true

func _ready() -> void:
	if piktogram_edition:
		Global.LogMetrics("Running Piktogram Edition")
	else:
		Global.LogMetrics("Running Text Edition")

func SetData(tutorial_data: TutorialDataModel, phase: int) -> void:
	_set_objective(		InputUtils.Convert(tutorial_data, tutorial_data.Objectives.get(phase)))
	_set_flavor(		InputUtils.Convert(tutorial_data, tutorial_data.ObjectiveFlavors.get(phase)))
	_set_control_title(	InputUtils.Convert(tutorial_data, tutorial_data.ControlHintTitles.get(phase)))
	_set_control_hint(	InputUtils.Convert(tutorial_data, tutorial_data.ControlHints.get(phase)))
	
	if piktogram_edition:
		$%HintDescription.visible = false
		$%HintDescription2.visible = true
		$%ObjectiveFlavor.visible = false
		
		match phase:
			0:
				$%HintDescription2.texture = load("res://user_interface/assets/tutorial_icons/GUX_KeteerMivm.png")
			1:
				$%HintDescription2.texture = load("res://user_interface/assets/tutorial_icons/GUX_KeteerJumpeSmallImprove.png")
			2:
				$%HintDescription2.texture = load("res://user_interface/assets/tutorial_icons/WorkingImageWhite.png")
			3:
				$%HintDescription2.texture = load("res://user_interface/assets/tutorial_icons/WorkingImage_white_boss.png")

func _set_objective(context: String) -> void:
	%ObjectiveLabel.text = context
	
func _set_flavor(context: String) -> void:
	%ObjectiveFlavor.text = context
	
func _set_control_title(context: String) -> void:
	%HintLabel.text = context
	
func _set_control_hint(context: String) -> void:
	%HintDescription.text = context
