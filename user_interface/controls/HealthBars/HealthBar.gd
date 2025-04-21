extends Control
class_name HealthBar

var Minimum: float 
var Current: float
var Maximum: float 

func SetHealth(minimum: float, current: float, maximum: float) -> void:
	Minimum = minimum
	Current = current
	Maximum = maximum
	
func ChangeHealth(current: float) -> void:
	Current = current
