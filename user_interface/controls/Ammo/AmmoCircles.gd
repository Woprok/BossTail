extends ColorRect
class_name AmmoIndicatorCircle

@export var draw_center: Vector2 = Vector2(32.0, 32.0)  # Center of 64x64
@export var position_y_adjust: float = 24.0
@export var circle_count: int = 3

@export var radius: float = 64.0  # Distance from center to each circle
@export var outer_circle_radius: float = 6.0
@export var inner_circle_radius: float = 5.0

@export var circle_color_ready: Color = Color.GREEN
@export var circle_color_missing: Color = Color.RED
@export var circle_color_border: Color = Color.WHITE

@export var circle_initial_degree: float = 270.0  # Top
@export var circle_degree_distance: float = 15.0

@export var ammo_ready: int = 3  # Example: 2 of 3 ammo available
@export var draw_special_visual: bool = false
@export var circle_color_ready_special: Color = Color.BLACK

func _init() -> void:
	color = Color.TRANSPARENT

func SetAmmo(current: int, max: int, special: bool) -> void:
	ammo_ready = current
	circle_count = max
	draw_special_visual = special
	queue_redraw()

func _draw():
	for i in circle_count:
		var angle = deg_to_rad(circle_initial_degree + (i - (circle_count - 1) * 0.5) * circle_degree_distance)
		var pos = draw_center + Vector2(cos(angle), sin(angle)) * radius
		pos.y += position_y_adjust

		draw_circle(pos, outer_circle_radius, circle_color_border, true)
		
		var is_ready = i < ammo_ready
		var fill_color = circle_color_missing
		if is_ready:
			fill_color = circle_color_ready
		draw_circle(pos, inner_circle_radius, fill_color, true)
		
		# Try to create illusion of Fly, as this is the only special ammo
		# TODO this should be more general in future, if we add additional specials	
		if draw_special_visual:
			_draw_fly(pos)
			
func _draw_fly(center: Vector2) -> void:
	draw_circle(center, outer_circle_radius, circle_color_ready_special, true)
	var wing_offset_x = 7
	var wing_offset_y = 6
	var wing_radius = 3.0
	# Left wing
	var left = center + Vector2(-wing_offset_x, -wing_offset_y)
	# Right wing
	var right = center + Vector2(wing_offset_x, -wing_offset_y)
	draw_circle(left, wing_radius, circle_color_border, true)
	draw_circle(right, wing_radius, circle_color_border, true)
