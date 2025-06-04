extends MeshInstance3D
class_name MeshParticle

@export var OneShot: bool = true
var started: bool

@export var Lifetime: float

var lifetime_timer: float = 0.0
var material: ShaderMaterial

func setup():
	material = self.get_active_material(0)
	if OneShot:
		started = true

func _ready():
	setup()
	update_particle(0.0)
	

func restart():
	started = true
	lifetime_timer = 0.0
	pass

func _process(delta: float) -> void:
	if not started:
		return

	if lifetime_timer > Lifetime:
		if OneShot:
			queue_free()
		else:
			started = false

	update_particle(lifetime_timer)
	lifetime_timer += delta
	pass
	
func update_particle(current_time: float):
	pass
