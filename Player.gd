extends CharacterBody2D

signal health_changed(health_value)

@onready var raycast = $Node2D/RayCast2D
@onready var camera = $Camera2D
@onready var node = $Node2D
var health = 3

const SPEED = 200.0
var gravity = 900.0
var JUMP_VELOCITY = -600
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	camera.make_current()
	
func _unhandled_input(event):
	if not is_multiplayer_authority(): return
		
	if Input.is_action_just_pressed("shoot"):
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			if !(hit_player is StaticBody2D):
				hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	

	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity.x = input_dir.x * SPEED
	#velocity.y = input_dir.y * SPEED
	velocity.y += gravity * delta
	move_and_slide()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector2.ZERO
	health_changed.emit(health)

