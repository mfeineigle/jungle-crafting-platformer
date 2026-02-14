extends Resource
class_name Item

@export var id: String
@export var display_name: String
@export var icon: Texture2D
@export var recipe_learn: String
@export var recipe_msg: String
@export var inputs: Array[Item]      # array of Item resources
@export var buildable: PackedScene
@export var build_offset_y: float = 0.0
