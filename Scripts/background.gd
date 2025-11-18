extends Node2D

# Size of your tiling texture in pixels (set this to match your image)
@export var texture_size: Vector2 = Vector2(1024, 1024)

# Node the background should follow (usually Camera2D or Player)
@export_node_path("Node2D") var follow_node: NodePath

var _tiles: Array[Sprite2D] = []
@onready var _base_sprite: Sprite2D = $BaseSprite


func _ready() -> void:
	# Create a 3x3 grid of sprites around (0, 0)
	_tiles.clear()

	for x in range(-1, 2):
		for y in range(-1, 2):
			var s := _base_sprite.duplicate() as Sprite2D
			add_child(s)
			s.position = Vector2(x, y) * texture_size
			_tiles.append(s)

	# Hide the original template sprite
	_base_sprite.visible = false


func _process(_delta: float) -> void:
	if follow_node.is_empty():
		return

	var target := get_node_or_null(follow_node) as Node2D
	if target == null:
		return

	# Use the followed node's position as basis
	var base_pos: Vector2 = target.global_position

	# Snap base offset to the texture grid
	var snapped_x: float = float(floor(base_pos.x / texture_size.x)) * texture_size.x
	var snapped_y: float = float(floor(base_pos.y / texture_size.y)) * texture_size.y
	var snapped: Vector2 = Vector2(snapped_x, snapped_y)

	# Center our tile grid around that snapped position
	var i := 0
	for x in range(-1, 2):
		for y in range(-1, 2):
			_tiles[i].global_position = snapped + Vector2(x, y) * texture_size
			i += 1
