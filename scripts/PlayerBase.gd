extends CharacterBody3D
class_name PlayerBase

# Common Preloads
@export var player_data: PlayerDataModel = preload("res://data_resources/PlayerDataModelInstance.tres")

# Common Mouse & Camera
@onready var Camera = $CameraPivot/SpringArm3D/Camera3D
@export var AIM_MOUSE_SENS:float = 0.004
@export var MOUSE_VERTICAL_SENS:float = 0.004
@export var MOUSE_SENS:float = 0.008
# Common Movement
var speed:int = 15
var jump_speed:int = 30

var fall_acceleration:int = 75
var DASH_SPEED:int = 25
var DASH_TIME:float = 0.5
@export var CamSpeedLines: CamSpeedLinesController
var AIM_SPEED:int = 5
var SPEED:int = 15

var back = -1
var lastHit = 100

var time:float = 0
var jump_time:float = 0
var target_velocity:Vector3 = Vector3.ZERO
var mouse_sensitivity:float = MOUSE_SENS

var melee:bool = false
var fighting:bool = false
var jump:bool = false
var dashing:bool = false
var can_dash:bool = true

var aiming:bool = false
var last_shot:float = 0
var direction = Vector3.ZERO

# rotation for camera
@export var CAMERA_MIN_X: float = -30
@export var CAMERA_MAX_X: float = 00
@export var AIM_CAMERA_MIN_X: float = -70
@export var AIM_CAMERA_MAX_X: float = 25

# Init
func _ready():
	player_data.player_restart()
	$CameraPivot.rotation.x = deg_to_rad(-8)	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if Input.is_action_pressed("aim"):
			Camera.rotation.x -= event.relative.y * mouse_sensitivity
			Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(AIM_CAMERA_MIN_X), deg_to_rad(AIM_CAMERA_MAX_X))
		else:
			Camera.rotation.x -= event.relative.y * MOUSE_VERTICAL_SENS
			Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(CAMERA_MIN_X), deg_to_rad(CAMERA_MAX_X))
			
			
func _start_dash() -> void:
	dashing = true
	player_data.change_dash_indicator(false)
	can_dash = false
	$dash_timer.start(DASH_TIME)
	$AnimationTree.dash_start()
	CamSpeedLines.appear(0.1)
	var dash_timing = create_tween()
	dash_timing.tween_callback(CamSpeedLines.fade.bind(0.15)).set_delay(DASH_TIME - 0.1)
	dash_timing.parallel().tween_callback($AnimationTree.dash_end).set_delay(DASH_TIME - 0.1)
	
func _handle_camera() -> void:
	if Input.is_action_pressed("camera_right"):
		rotate_y(-0.05)
	if Input.is_action_pressed("camera_left"):
		rotate_y(0.05)
	if Input.is_action_pressed("camera_up"):
		Camera.rotation.x += deg_to_rad(0.8)
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(CAMERA_MIN_X), deg_to_rad(CAMERA_MAX_X))
	if Input.is_action_pressed("camera_down"):
		Camera.rotation.x -= deg_to_rad(0.8)
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(CAMERA_MIN_X), deg_to_rad(CAMERA_MAX_X))
	
func _stab_started() -> void:
	$AnimationTree.lunge_r()
	fighting=true
	player_data.change_melee_indicator(false)
	
func _aim_started() -> void:
	player_data.change_melee_indicator(false)
	player_data.change_ranged_indicator(true)
	aiming = true
	mouse_sensitivity = AIM_MOUSE_SENS
	speed = AIM_SPEED
	$CameraPivot/zoom.speed_scale = 3
	Camera.get_node("target").show()
	$CameraPivot/zoom.play("zoom")
	
func _aim_finished() -> void:
	player_data.change_melee_indicator(true)
	player_data.change_ranged_indicator(false)	
	aiming = false
	mouse_sensitivity = MOUSE_SENS
	speed = SPEED
	Camera.get_node("target").hide()
	$CameraPivot/zoom.speed_scale = 1
	Camera.rotation.x = deg_to_rad(-20)
	$CameraPivot/zoom.play_backwards("zoom")


func _on_pickup_entered(body):
	if body.is_in_group("pebble") and player_data.ammo_standard.can_pick():
		player_data.player_ammo_picked()
		body.queue_free()

func _shoot(projectile) -> void:
	projectile.global_position = position - transform.basis.z * 2
	projectile.velocity = - transform.basis.z
	
	var space_state = Camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = Camera.project_ray_origin(screen_center)
	var end = origin + Camera.project_ray_normal(screen_center) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	projectile.shoot(origin, end, result)
