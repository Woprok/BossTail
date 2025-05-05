extends PanelContainer
class_name TutorialHint

func SetObjective(objective_title: String, objective_flavor: String) -> void:
	%ObjectiveLabel.text = objective_title
	%ObjectiveFlavor.text = objective_flavor
	
func SetHint(hint_title: String, hint_description: String) -> void:
	%HintLabel.text = hint_title
	%HintDescription.text = hint_description
