extends Node2D

@export var spawn_interval := 2.0
@export var spawn_min_dist := 100.0
@export var spawn_max_dist := 200.0
@export var MAX_ENEMIES_ON_SCREEN := 8

@export var ENEMY_POOL_A: Array[PackedScene] = []
@export var ENEMY_POOL_B: Array[PackedScene] = []
@export var DIVIDE_X_POS := 500.0

var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIES_ON_SCREEN:
		return
	spawn_enemy()

func spawn_enemy():
	var player := get_parent() as CharacterBody2D

	var pool := ENEMY_POOL_A if player.global_position.x < DIVIDE_X_POS else ENEMY_POOL_B
	if pool.is_empty():
		return

	var enemy = pool.pick_random().instantiate()
	get_parent().get_parent().add_child(enemy) # add to Main/world

	enemy.global_position = determine_spawn_position(player.global_position)
	print(enemy.global_position)

func determine_spawn_position(player_pos: Vector2) -> Vector2:
	var dist = randf_range(spawn_min_dist, spawn_max_dist)
	var angle = randf() * TAU
	return player_pos + Vector2(cos(angle), sin(angle)) * dist
