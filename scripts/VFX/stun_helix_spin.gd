extends MeshInstance3D

@export var SpinSpeed: float

func _process(delta: float) -> void:
	self.rotate_y(-deg_to_rad(SpinSpeed * delta))
