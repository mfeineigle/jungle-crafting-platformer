extends Camera3D
@onready var c1: StaticBody3D = $"../Cylinder"
@onready var col1: CollisionShape3D = $"../Cylinder/CollisionShape3D"

@onready var c2: StaticBody3D = $"../Cylinder2"
@onready var col2: CollisionShape3D = $"../Cylinder2/CollisionShape3D"
@onready var glider: StaticBody3D = $"../glider/glider"

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var animation_player2: AnimationPlayer = $"../AnimationPlayer2"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_ray()

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var ray_result = space.intersect_ray(ray_query)
	if ray_result:
		print(ray_result.collider)
		detect_button(ray_result.collider)

	
func detect_button(collider):
	match collider:
		c1:
			c1.hide()
			col1.disabled = true
			animation_player.play("new_animation")
			c2.show()
			col2.disabled = false
		c2:
			c1.show()
			col1.disabled = false
			animation_player.play("new_animation")
			c2.hide()
			col2.disabled = true
		glider:
			animation_player2.play("spin")
