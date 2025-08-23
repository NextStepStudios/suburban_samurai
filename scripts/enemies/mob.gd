# mob.gd

extends CharacterBody2D

# state machine enums
enum {PATROL, CHASE}
var state = PATROL # init
var player = null # hold ref to Nico's player lol

# ready nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var ground_check_ray = $RayCast2D
@onready var sfx_player = $SFXPlayer

# vars
var speed = 50 # walk speed
var direction: float # init only
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# file paths
const NINJA_SOUND = preload("res://assets/audio/enemies/ninja/ninja_sound.mp3")

func _ready():
	# randi() % 2 gives us either 0 or 1, perfect 50/50 chance
	if randi() % 2 == 0: # if even
		direction = 1.0 # Go right
	else: # if odd
		direction = -1.0 # Go le

func _physics_process(delta):
	# state machine
	match state:
		PATROL:
			patrol_state(delta)
		CHASE:
			chase_state(delta)

# mob movement (old _physics_process func)
func patrol_state(delta):
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta # incr with -y acceleration

	# if ray not colliding with anything, means it's at an edge
	if not ground_check_ray.is_colliding():
		direction *= -1.0 # flip the direction

	# general velocity
	velocity.x = direction * speed

	# flip_h true if -1 (left), false if 1 (right, default)
	animated_sprite.flip_h = direction > 0
	
	# stateless raycast flip
	# set ray's direction based on the 'direction' variable every frame
	if direction > 0: # moving right
		ground_check_ray.target_position.x = abs(ground_check_ray.target_position.x)
	else: # moving left
		ground_check_ray.target_position.x = -abs(ground_check_ray.target_position.x)
		
	animated_sprite.play("Idle") # walk animation
	move_and_slide() # godots magic func for sliding on floor

# mob chase state
func chase_state(delta):
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# edge case
	# if player disappears, go back to patrolling
	if not is_instance_valid(player):
		state = PATROL
		return
	
	# calc direction to player and move towards them
	# player - mob position to get either + or - value
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# update direction
	if direction_to_player.x > 0: # player to the right
		direction = 1 # right
	else:
		direction = -1 # left
		
	# apply velocity vector with chase speed boost
	velocity.x = direction_to_player.x * speed * 4 # chase a bit faster

	# standard sprite flip and walk logic
	animated_sprite.flip_h = velocity.x > 0
	animated_sprite.play("walk")
	move_and_slide()


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("ENEMY: Entered Aggro State") # debug
		state = CHASE # set mob to hunt the player
		player = body # the body it chases is the player
		
		sfx_player.stream = NINJA_SOUND # set SFX
		sfx_player.play() # play SFX
