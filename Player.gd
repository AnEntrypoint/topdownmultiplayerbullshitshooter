extends CharacterBody2D

signal health_changed(health_value)

@onready var raycast = $Node2D/RayCast2D
@onready var camera = $Camera2D
@onready var node = $Node2D
@onready var sprite = $AnimatedSprite2D
@onready var target = $Node2D/Icon2
var health = 3

const SPEED = 200.0
var gravity = 0.0
var JUMP_VELOCITY = -600
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	sprite.play()
	sprite.speed_scale = 0.5
	if not is_multiplayer_authority(): return
	camera.make_current()
	
func _unhandled_input(event):
	if not is_multiplayer_authority():
		target.visible = false
		return
		
	if Input.is_action_just_pressed("shoot"):
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			if !(hit_player is StaticBody2D):
				hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

var lastpos = position
var animation = "idle"
var direction = "down"
var lastcheck = 0
func _process(delta):
	lastcheck += delta
	if lastcheck > 0.05:
		lastcheck = 0
		var dir = position - lastpos
		lastpos = position
		if dir.y > 0 || dir.y < 0 || dir.x > 0 || dir.x < 0:
			if dir.y < 0:
				animation = "walking"
				direction = "up"
			if dir.y > 0:
				animation = "walking"
				direction = "down"
			if dir.x < 0:
				animation = "walking"
				direction = "left"
			if dir.x > 0:
				animation = "walking"
				direction = "right"
			sprite.speed_scale = 3
		else:
			animation = "idle"
			sprite.speed_scale = 0.5
	sprite.animation = animation+direction


func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")

	if is_multiplayer_authority():
		velocity.x = input_dir.x * SPEED
		velocity.y = input_dir.y * SPEED
		#velocity.y += input_dir * delta
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

