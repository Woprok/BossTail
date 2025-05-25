extends ScreenBase
class_name GameScreenBase
# Common parent for all game screens, which is just a HUD and NoneScreen

func _init() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
