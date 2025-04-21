extends Node
# Manages ingame global signals and appropriate callbacks if necessary
# class_name GameEvents #Defined as autoloaded Global

# Basically, this exists to following issue:
# If Boss is loaded it needs to announce it's data
# If HUD is loaded it needs to get current Boss data
# Problem, unless we want to explicitely say, which should happen first
# we meed to be prepared for both cases of either being first
# Thus the current solution is for boss to announce and HUD to read and listen  

func _ready() -> void:
	boss_changed.connect(func(data: BossDataModel): boss_data = data)

var boss_data: BossDataModel
signal boss_changed(data: BossDataModel)
