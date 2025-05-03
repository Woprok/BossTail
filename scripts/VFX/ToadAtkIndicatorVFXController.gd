extends Node3D

var vfxTweener: Tween
var indicMesh: MeshInstance3D

func appear(scale_in_dur: float):
	if vfxTweener.finished or vfxTweener == null:
		vfxTweener = self.create_tween()
	else:
		vfxTweener.kill()
	self.scale = Vector3.ZERO
	vfxTweener.tween_property(self, "scale", Vector3.ONE, scale_in_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func fade(duration: float):
	#TODO tween shader opacity property to zero
	pass
