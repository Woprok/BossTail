extends Node3D
class_name WhirlwindVFXController

@export var WhirlwindStrands: Array[WhirlwindStrand]
@export var Shockwave: MeshParticleBase
@export var ShockwaveLifetime: float


func fade_whirlwind(dur: float):
	for w in WhirlwindStrands:
		w.fade(dur)

func appear_whirlwind(dur: float):
	for w in WhirlwindStrands:
		w.appear(dur)

func shockwave():
	Shockwave.Lifetime = ShockwaveLifetime
	Shockwave.restart()
	
	Shockwave.rotation = Vector3.ZERO
	create_tween().tween_property(Shockwave, "rotation", Vector3(0,180,0), ShockwaveLifetime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
