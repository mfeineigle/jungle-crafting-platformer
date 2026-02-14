extends Control

const SPRITE_SIZE = Vector2(64, 64)

@export var bkg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 4

@export var options = []

var selection = null

func _draw() -> void:
	var offset = SPRITE_SIZE / -2
	
	# draw center circle
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)

	if len(options) >= 3:
		# draw separator lines
		for i in range(len(options) - 1	):
			var rads = TAU * i / (len(options) - 1)
			var point = Vector2.from_angle(rads)
			draw_line(point * inner_radius, point * outer_radius, line_color, line_width, true)
		# draw highlight
		if selection == 0:
			draw_circle(Vector2.ZERO, inner_radius, highlight_color)
		# center label
		draw_texture_rect(options[0].icon, Rect2(offset, SPRITE_SIZE), false)
		# build segments
		for i in range(1, len(options)):
			var start_rads = (TAU * (i-1)) / (len(options) - 1)
			var end_rads = (TAU * i) / (len(options) - 1)
			var mid_rads = (start_rads + end_rads) / 2.0 * -1
			var radius_mid = (inner_radius + outer_radius) / 2.0
			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			if selection == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				for j in range(points_per_arc + 1):
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
				points_outer.reverse()
				draw_polygon( points_inner + points_outer, PackedColorArray([highlight_color]))
			# segment labels
			draw_texture_rect(options[i].icon, Rect2(draw_pos, SPRITE_SIZE), false)
	
			
			
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius <= inner_radius:
		selection = 0	
	elif mouse_radius > inner_radius:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selection = ceil((mouse_rads / TAU) * (len(options) - 1))
	#print(selection)
	queue_redraw()
