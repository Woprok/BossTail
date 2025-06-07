extends ProjectileBase
class_name FlyProjectile

var platform = null

func _on_area_entered(area):
	if area.is_in_group("platform"):
		platform = area

func _on_area_exited(area):
	if area.is_in_group("platform"):
		platform = null

func is_pickable() -> bool:
	return platform != null and super.is_pickable()
