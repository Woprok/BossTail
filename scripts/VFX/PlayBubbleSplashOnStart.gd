extends PlayParticleSysOnStart
class_name PlayBubbleSplashOnStart

@onready var puddle : PuddleController = $Puddle
@export var PuddleFadeTime: float
@export var AdditionalPuddleComponents: Array[Node3D]
var create_puddle: bool = true

func _ready() -> void:
	play_particle_systems()
	if create_puddle:
		puddle.setup()
		puddle.puddle_appear(0.2)
	else: #disable additional puddle components
		for obj in AdditionalPuddleComponents:
			obj.queue_free()
	
	if DestroyInSeconds > 0:
		if create_puddle:
			create_tween().tween_callback(fade_puddle_and_destroy).set_delay(DestroyInSeconds)
		else:
			create_tween().tween_callback(queue_free).set_delay(DestroyInSeconds)

func fade_puddle_and_destroy():
	puddle.puddle_fade(PuddleFadeTime)
	create_tween().tween_callback(queue_free).set_delay(PuddleFadeTime + 0.1)
