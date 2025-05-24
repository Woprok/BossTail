extends PanelContainer
class_name AmmoIndicator

func ChangeAmmo(ammo: AmmoStatus) -> void:
	%AmmoColorRect.SetAmmo(ammo.current, ammo.max, ammo.is_special)
