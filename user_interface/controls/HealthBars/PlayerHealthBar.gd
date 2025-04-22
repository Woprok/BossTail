extends HealthBar
class_name PlayerHealthBar

var DamageBarTween: Tween
@export var DamageBarTweenDuration: float = 0.5

func SetHealth(minimum: float, current: float, maximum: float) -> void:
	super(minimum, current, maximum)
	%HealthBar.min_value = Minimum
	%HealthBar.max_value = Maximum
	%HealthBar.value = Current
	%DamageBar.min_value = Minimum
	%DamageBar.max_value = Maximum
	%DamageBar.value = Current

func ChangeHealth(current: float) -> void:
	super(current)
	
	if DamageBarTween:
		DamageBarTween.kill()
		
	DamageBarTween = get_tree().create_tween()
	DamageBarTween.tween_property(%DamageBar, "value", Current, DamageBarTweenDuration) \
				  .set_trans(Tween.TRANS_CUBIC) \
				  .set_ease(Tween.EASE_IN)
				
	%HealthBar.value = Current
