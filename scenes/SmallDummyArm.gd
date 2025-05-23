extends MeshInstance3D
class_name SmallDummyArm

@export var RotationSpeed: float

func rotate_arm(delta: float) -> void:
	rotate_y(RotationSpeed * delta)
