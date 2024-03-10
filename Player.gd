extends CharacterBody2D

signal health_changed(health_value)

@onready var raycast = $RayCast2D

var health = 3

const SPEED = 200.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return

func _unhandled_input(event):
	if event:
		if not is_multiplayer_authority(): return
		
	if Input.is_action_just_pressed("shoot"):
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	look_at(get_global_mouse_position())
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity.x = input_dir.x * SPEED
	velocity.y = input_dir.y * SPEED

	move_and_slide()

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector2.ZERO
	health_changed.emit(health)

