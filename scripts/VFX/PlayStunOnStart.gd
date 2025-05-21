extends PlayParticleSysOnStart
class_name PlayStunVFXOnStart

@export var HelixStartPos: Node3D
@export var HelixStartOffset: Vector3 = Vector3.ZERO
@export var HelixRiseAmount: float
@export var HelixFadeInDur: float
@export var HelixRiseTime: float
@export var HelixMaxScale: float
@export var HelixMinScale: float
@export var HelixScaleTime: float

var StunDuration: float = 2.0

@export var HelixMesh: MeshInstance3D
var stunHelixMaterial: StandardMaterial3D
var stunHelixDefaultColor: Color

var helixTweener: Tween

func _ready() -> void:
	self.init()
	stunHelixMaterial = HelixMesh.get_active_material(0)
	stunHelixDefaultColor = stunHelixMaterial.albedo_color
	
	_fadeInScaleHelix()
	
func _fadeInScaleHelix():
	if helixTweener != null and helixTweener.is_running():
		helixTweener.kill()
	helixTweener = create_tween()
	
	if HelixStartPos != null:
		HelixMesh.global_position = HelixStartPos.global_position
	else:
		HelixMesh.position += HelixStartOffset
		
	HelixMesh.scale = Vector3.ONE * HelixMinScale
	stunHelixMaterial.albedo_color.a = 0.1
	var targetHelixPos = HelixMesh.position + Vector3.UP * HelixRiseAmount
	
	helixTweener.tween_property(stunHelixMaterial, "albedo_color", stunHelixDefaultColor, HelixFadeInDur)
	helixTweener.parallel().tween_property(HelixMesh, "scale", Vector3.ONE * HelixMaxScale, HelixScaleTime)
	helixTweener.parallel().tween_property(HelixMesh, "position", targetHelixPos, HelixRiseTime)
	helixTweener.parallel().tween_property(stunHelixMaterial, "albedo_color", Color.TRANSPARENT, HelixFadeInDur).set_delay(StunDuration)
	
