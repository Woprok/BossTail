extends ProjectileBase
class_name FlyProjectile

@export_category("Death")
@export var projectile_healing: float = 1.0

var platform = null

func _on_area_entered(area):
	if area.is_in_group("platform"):
		platform = area

func _on_area_exited(area):
	if area.is_in_group("platform"):
		platform = null

func is_pickable() -> bool:
	return platform != null and super.is_pickable()

func start_decay_timer() -> void:
	$DecayTimer.start()

func _on_decay_timer_timeout() -> void:
	destroy()
