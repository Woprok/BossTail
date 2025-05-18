@tool
extends Area3D
class_name TutorialPoint

@export var tutorial_point_size: Vector3 = Vector3(25, 25, 25):
	set(value):
		tutorial_point_size = value
		_update_shape()
@export var tutorial_point_id: int = -1

#func _ready() -> void:
#	_update_shape()
	
func _update_shape() -> void:
	%CollisionShape3D.shape.size = tutorial_point_size

func _ready() -> void:
	_update_shape()
	if tutorial_point_id == -1:
		Global.LogError("TutorialPoint: Id was not set.")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):	
		Global.LogInfo("TutorialPoint: Player entered.")
		GameEvents.tutorial_phase.emit(tutorial_point_id)
		queue_free()
