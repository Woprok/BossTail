extends MeshParticle
class_name MeshParticleBase

@export var LifetimeParamCurves: Dictionary[String, Curve]

#@export var LifetimeProperties: Dictionary[String, Variant]
@export var ScaleOverLifetime: CurveXYZTexture

#func setup():
#	super()
	
#func _process(delta: float) -> void:
#	super(delta)

func update_particle(current_time: float):
	var time_normalized: float = current_time / Lifetime
	
	for param_name in LifetimeParamCurves.keys():
		var param_curve: Curve = LifetimeParamCurves[param_name]
		update_particle_param_curve(time_normalized, param_name, param_curve)
	
	update_scale(time_normalized)
	pass
	
func update_scale(time_normalized: float):
	if ScaleOverLifetime == null:
		return
	
	var x = ScaleOverLifetime.curve_x.sample(time_normalized)
	var y = ScaleOverLifetime.curve_y.sample(time_normalized)
	var z = ScaleOverLifetime.curve_z.sample(time_normalized)
	self.scale = Vector3(x,y,z)
	
func update_particle_param_curve(time_normalized: float, param_name: String, param_val_curve: Curve):
	
	var value_at_time: float = param_val_curve.sample(time_normalized)
	material.set_shader_parameter(param_name, value_at_time)
