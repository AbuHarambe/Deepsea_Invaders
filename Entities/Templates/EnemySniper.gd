extends BaseRangedBlubblub

@export_group("Sniper Settings")
@export var ammo_scene: PackedScene # Hier Projectile.tscn reinziehen
@export var shot_cooldown: float = 3.0
@export var aim_time: float = 1.0
@export var projectile_speed: float = 800.0

var attack_timer: float = 0.0
var is_aiming: bool = false
@onready var line_2d = $Line2D # Füge einen Line2D Node zur Szene hinzu für den Laser!

func _ready():
	if line_2d: line_2d.visible = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta) # Normale Bewegung (Kiting)
	
	attack_timer -= delta
	
	if is_instance_valid(player):
		# Zielen Visualisierung
		if is_aiming:
			line_2d.visible = true
			line_2d.points = [Vector2.ZERO, to_local(player.global_position)]
		else:
			if line_2d: line_2d.visible = false

		# Angriff starten
		if attack_timer <= 0 and not is_aiming:
			start_aiming()

func start_aiming():
	is_aiming = true
	# Optional: Sound abspielen
	
	await get_tree().create_timer(aim_time).timeout
	
	if not in_scanner and is_instance_valid(player): # Nicht schießen wenn man gerade eingesaugt wird
		shoot()
	
	is_aiming = false
	attack_timer = shot_cooldown

func shoot():
	var projectile = ammo_scene.instantiate()
	get_parent().add_child(projectile) # In die Welt einfügen
	projectile.global_position = global_position
	
	var dir = (player.global_position - global_position).normalized()
	projectile.velocity = dir * projectile_speed
	projectile.rotation = dir.angle()
