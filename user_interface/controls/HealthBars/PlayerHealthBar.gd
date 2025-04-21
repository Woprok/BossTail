extends HealthBar
class_name PlayerHealthBar

var DamageBarTween: Tween
@export var DamageBarTweenDurationPerPercent: float = 0.75

func SetHealth(minimum: float, current: float, maximum: float) -> void:
	super(minimum, current, maximum)
	%HealthBar.min_value = Minimum
	%HealthBar.max_value = Maximum
	%HealthBar.value = Current
	%DamageBar.min_value = Minimum
	%DamageBar.max_value = Maximum
	%DamageBar.value = Current

func ChangeHealth(current: float) -> void:
	var difference: float = Current - current
	super(current)
	
	if DamageBarTween:
		DamageBarTween.kill()
		
	DamageBarTween = get_tree().create_tween()
	DamageBarTween.tween_property(%DamageBar, "value", Current, difference * DamageBarTweenDurationPerPercent) \
				  .set_trans(Tween.TRANS_BOUNCE) \
				  .set_ease(Tween.EASE_OUT)
				
	%HealthBar.value = Current
