extends Node3D
class_name StunVFX

@export var StunVFXPrefab: PackedScene

@export var ImpactPos: Node3D
@export var HelixStartPos: Node3D
@export var DefaultStunDuration: float = 2

@export var HelixScaleMin: float = 0.1
@export var HelixScaleMax: float = 0.6

func play_stun_effect(duration: float = DefaultStunDuration):
	var vfxNode: PlayStunVFXOnStart = StunVFXPrefab.instantiate()
	get_parent().add_child(vfxNode)
	vfxNode.global_position = ImpactPos.global_position
	vfxNode.HelixStartPos = HelixStartPos
	vfxNode.HelixMaxScale = HelixScaleMax
	vfxNode.HelixMinScale = HelixScaleMin
	vfxNode.StunDuration = duration
	vfxNode.DestroyInSeconds = duration + vfxNode.HelixFadeInDur
