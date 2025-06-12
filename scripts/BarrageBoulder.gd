extends CharacterBody3D
class_name BarrageBoulder

var pos_index = 0
var time = 0
var thrown = false
var hitted = false
var dummy_box = false
var dummy_parent = null
var projectile_drop = preload("res://scenes/player/PebbleProjectile.tscn")
@onready var mesh: MeshInstance3D = $BoulderMesh
#@onready var collisionShape: CollisionShape3D = $CollisionShape3D

@export var RollSpeed: float
@export var SpawnDropDur: float = 0.75
@export var AppearScaleDur: float = 0.35
@export var BoulderMeshScale: float = 4.0
var spawn_drop_running: bool

func spawn_drop(ground_y: float):
	#print("pos y: " + str(position.y) + " ground_y; " + str(ground_y))
	spawn_drop_running = true
	var drop_height = self.position.y - ground_y
	var drop_pos: Vector3 = position - Vector3(0, drop_height, 0) + Vector3.UP * 1.0
	mesh.scale = Vector3.ZERO
	var tween = get_tree().create_tween()
	tween.tween_property(mesh, "scale", Vector3.ONE * BoulderMeshScale, AppearScaleDur)
	tween.tween_property(self, "position", drop_pos, SpawnDropDur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(spawn_drop_finished)
	
func spawn_drop_finished():
	spawn_drop_running = false
	
func _physics_process(delta):
	mesh.rotate_x(deg_to_rad(RollSpeed) * delta)
	
	if spawn_drop_running: 
		return
	
	time += delta
	if dummy_box:
		return
	if thrown==false:
		if not is_on_floor():
			velocity.y = -10
		move_and_slide()
		if time>30:
			get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
			queue_free()
	else:
		if time>30:
			queue_free()
		if not is_on_floor():
			velocity.y = -10
		move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player") and not thrown and not dummy_box:
		body.hit(null, 10)
		get_parent().get_parent().get_parent().num_of_crates[pos_index]-=1
		queue_free()


func _on_hit_body_entered(body):
	if body.is_in_group("player") and not dummy_box :
		if body.position.y+0.1>=position.y+3*scale.y:
			_spawn_rock()
			queue_free()
		else:
			body.hit(null, 5)
			_spawn_rock()
			queue_free()
	if body.is_in_group("player_projectile"):
		if dummy_box:
			if dummy_parent.stopped:
				return 
			dummy_parent._on_box_hit(body)
		body.queue_free()
		queue_free()
	#if body.is_in_group("box") and time>0.4:
	#	body.queue_free()

func _on_hit_area_entered(area: Area3D) -> void:
	if area.is_in_group("spike") and not hitted:
		hitted = true
		_spawn_rock()
		queue_free()

func _spawn_rock() -> void:
	var np = projectile_drop.instantiate()
	get_tree().root.add_child(np)
	np.global_position = position
