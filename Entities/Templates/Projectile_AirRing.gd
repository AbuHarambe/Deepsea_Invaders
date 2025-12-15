extends Area2D

@export var speed: float = 200.0
@export var damage: int = 15
@export var growth_rate: float = 1.5 # Wie schnell er größer wird
@export var max_size: float = 4.0    # Wann er platzt
@onready var player = get_tree().get_first_node_in_group("player_group")

var velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# 1. Bewegung nach vorne
	position += velocity * delta
	
	# 2. Größer werden (AoE Effekt)
	# Wir addieren delta auf den Scale-Vektor (x und y)
	scale += Vector2(delta, delta) * growth_rate
	
	# 3. Zerstören, wenn zu groß (damit er nicht unendlich Map abdeckt)
	if scale.x >= max_size:
		pop_bubble()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		if body.has_method("take_damage"):
			player.take_damage(damage)
			pop_bubble()
		# Optional: Ring zerstören beim Treffer? 
		# Bei AoE lässt man ihn oft weiterfliegen ("Durchschlag").
		# Wenn er platzen soll, nutze: pop_bubble()

func pop_bubble():
	# Hier könnte man noch eine kleine "Platz"-Animation abspielen
	queue_free()
