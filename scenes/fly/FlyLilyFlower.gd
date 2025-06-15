extends Area3D
class_name FlyLilyFlower

@export_category("Fly & Swarm")
@export var owned_swarm: Node3D

func _on_area_entered(area: Area3D) -> void:
	print("ERR THIS IS HIT BY SOMETHING")
	pass # Replace with function body.
