extends Panel
class_name TutorialHint

func SetHint(hint_title: String, hint_description: String) -> void:
	%HintLabel.text = hint_title
	%HintDescription.text = hint_description
