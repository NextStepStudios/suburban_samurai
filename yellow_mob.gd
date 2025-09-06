# mob.gd

extends CharacterBody2D

# state machine enums
enum {PATROL, CHASE, HURT, DIE, ATTACK}
var state = PATROL # init
var player = null # hold ref to Nico's player lol

# ready nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var ground_check_ray = $RayCast2D
@onready var sfx_player = $SFXPlayer
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var mob_hitbox: Area2D = $mob_hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# vars
var speed = 50 # walk speed
var direction: float # init only
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback_decay: float = 10.0  # higher = faster stop
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_strength: float = 200.0
var hurt_time: float = 0.4
var hurt_timer: float = 0.0
var health: int
var is_dead: bool = false
var attack_damage: int = 10
var can_damage:bool = true
# file paths
const NINJA_SOUND = preload("res://assets/audio/enemies/ninja/ninja_sound.mp3")

func _ready():
	# randi() % 2 gives us either 0 or 1, perfect 50/50 chance
	if randi() % 2 == 0: # if even
		direction = 1.0 # Go right
	else: # if odd
		direction = -1.0 # Go le
	health = 50
	health_bar.max_value = health

func _physics_process(delta):
	# state machine
	match state:
		PATROL:
			patrol_state(delta)
		CHASE:
			chase_state(delta)
		HURT:
			hurt(delta)
		DIE:
			die(delta)
		ATTACK:
			attack(delta)

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
		
	animated_sprite.play("idle") # walk animation
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

func attack(delta):
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
	animation_player.play("attack")
	move_and_slide()
		
		

func hurt (delta):
	
	animated_sprite.play("hurt")
	# Apply gravity if not grounded
	if not is_on_floor():
		velocity.y += gravity * delta
	# Apply knockback
	velocity.x = knockback_velocity.x
	velocity.y = knockback_velocity.y
	# Decay knockback smoothly
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	
	
	# Countdown hurt duration
	hurt_timer -= delta
	if hurt_timer <= 0.0:
		state = CHASE
	move_and_slide()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("ENEMY: Entered Aggro State") # debug
		state = CHASE # set mob to hunt the player
		player = body # the body it chases is the player
		
		#sfx_player.stream = NINJA_SOUND # set SFX
		#sfx_player.play() # play SFX
		
		
func hit(knockback_dir: Vector2, damage):
	# Called by the player when hit
	health -= damage
	health_bar.value = health
	if health > 0:
		state = HURT
		hurt_timer = hurt_time
	# only take horizontal direction
		var dir_x = sign(knockback_dir.x)
		if dir_x == 0:
			dir_x = 1 # fallback if same x position as player

		knockback_velocity = Vector2(dir_x * knockback_strength, -20) 
	# ↑ gives horizontal push + small upward bump
	else:
		state = DIE
	
func die(delta):
	if is_dead:
		return   # already dying, don’t repeat
	is_dead = true
	velocity.x = 0
	$CollisionShape2D.disabled = true
	animation_player.stop()
	animated_sprite.play("die")
	can_damage = false
	move_and_slide()
	await get_tree().create_timer(2).timeout
	queue_free()
	


func _on_mob_hitbox_body_entered(body: Node2D) -> void:
	print ("mob hitbox")
	
	
	if body.is_in_group("player") and not is_dead: #and can_damage:
		#can_damage = false
		attack_timer.start()
		if body.has_method("player_hit"):
			var dir = (body.global_position - global_position).normalized()
			body.player_hit(dir,attack_damage)
		



#func _on_attack_timer_timeout() -> void:
	#can_damage = true


func _on_attack_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		print("ENEMY: Entered Aggro State") # debug
		state = ATTACK # set mob to hunt the player
		player = body # the body it chases is the player
		
		sfx_player.stream = NINJA_SOUND # set SFX
		sfx_player.play() # play SFX


func _on_attack_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		print("ENEMY: Entered Aggro State") # debug
		state = CHASE # set mob to hunt the player
		player = body # the body it chases is the player


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		print("ENEMY: Entered Aggro State") # debug
		state = PATROL # set mob to hunt the player
		player = body # the body it chases is the player
