extends CanvasLayer

var materials: Array[ParticleProcessMaterial]
var dir_path: String = "res://assets/particle_process_materials/"

func _ready() -> void:
	load_materials()
	
	for material in materials:
		var particle_instance = GPUParticles3D.new()
		particle_instance.process_material = material
		particle_instance.one_shot = true
		particle_instance.emitting = true
		particle_instance.amount = 1
		self.add_child(particle_instance)
	
func load_materials() -> void:
	var dir = DirAccess.open(dir_path)
	
	if dir != null:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".tres"):
					var full_path = dir_path + file_name
					var material = load(full_path)
					print("Loaded particle mat -> " + full_path)
					if material is ParticleProcessMaterial:
						materials.append(material)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open dir: ", dir_path)
