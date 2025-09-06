# player.gd
class_name Player
extends CharacterBody2D

@onready var control_anim: AnimatedSprite2D = $Camera2D/CanvasLayer/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var canvas_layer: CanvasLayer = get_node("CanvasLayer")
@onready var health_bar: TextureProgressBar = canvas_layer.get_node("TextureProgressBar")


@onready var hitbox: Area2D = $hitbox

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D

enum {FLOOR, AIR, HURT, DIE}
var state = FLOOR
#contants for health

var health: int

# Constants for movement
const SPEED: int = 300
const JUMP_VELOCITY = -550
var attacking: bool = false
var attacking2: bool = false
#preloaded graity from gadot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Input.get_axis("left", "right")
var hitbox_base_offset: Vector2
var attack_damage: int
var knockback_decay: float = 10.0  # higher = faster stop
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_strength: float = 200.0
var dead: bool = false

func _ready():
	hitbox.monitoring = false
	health = 200
	health_bar.max_value = health
	health_bar.value = health
	hitbox_base_offset = hitbox.position  # store initial offset

func _physics_process(delta: float) -> void:
	match state:
		FLOOR:
			floor_state(delta)
		AIR:
			air_state(delta)
		HURT:
			hurt_state(delta)
		DIE:
			die_state(delta)
	
	
func floor_state(delta):
	var direction = Input.get_axis("left", "right")
	#Movement code
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# add gravity
	#if  not is_on_floor():
		#velocity += get_gravity() * delta
		#jump code
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	if not is_on_floor():
		state = AIR
	
	#play animation logic
	if attacking:
		animation_player.play("attack")
	elif attacking2:
		animation_player.play("test_attack")
	else:
		#if is_on_floor():
			if direction  == 0:
				anim_player.play("idle")
			else:
				anim_player.play("run")
		#else:
			#if Input.is_action_pressed("jump"):
				#anim_player.play("jump")
	
	# Flip sprite on movement
	if direction > 0:
		anim_player.flip_h =  false
		hitbox.position.x = abs(hitbox_base_offset.x)
		hitbox.scale.x = 1
	elif direction < 0:
		anim_player.flip_h = true
		hitbox.position.x = -abs(hitbox_base_offset.x)
		hitbox.scale.x = -1
		

	if Input.is_action_just_pressed("attack", true) and not attacking:
		_is_attacking()
		
	if Input.is_action_just_pressed("attack2", true) and not attacking2:
		_is_attacking2()
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	move_and_slide()
	
func air_state(delta):
	
	if attacking:
		animation_player.play("air_attack")
	else:
		anim_player.play("jump")
	var direction = Input.get_axis("left", "right")
	#add gravity
	if  not is_on_floor():
		velocity += get_gravity() * delta
	#Movement code
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction > 0:
		anim_player.flip_h =  false
		hitbox.position.x = abs(hitbox_base_offset.x)
		hitbox.scale.x = 1
	elif direction < 0:
		anim_player.flip_h = true
		hitbox.position.x = -abs(hitbox_base_offset.x)
		hitbox.scale.x = -1
	if is_on_floor():
		state = FLOOR
		
	if Input.is_action_just_pressed("attack", true) and not attacking:
		_is_attacking()
		
	move_and_slide()

func hurt_state(delta):
	animation_player.play("hurt")
	velocity.x = knockback_velocity.x
	velocity.y = knockback_velocity.y
	# Decay knockback smoothly
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	move_and_slide()
	
func die_state(delta):
	if  not is_on_floor():
		velocity += get_gravity() * delta
	if not dead:
		animation_player.play("die")
		dead = true
	move_and_slide()
	


func _is_attacking():
	attacking = true
	attack_damage = 10
func _is_attacking2():
	attacking2 = true
	attack_damage = 20
	
func player_hit (knockback_dir: Vector2, damage):
	print("player hit")
	health -= damage
	health_bar.value = health
	if health > 0:
		state = HURT
		var dir_x = sign(knockback_dir.x)
		if dir_x == 0:
			dir_x = 1 # fallback if same x position as player
		knockback_velocity = Vector2(dir_x * knockback_strength, 0) 
	else:
		if not dead:
			state = DIE
			
	
	

func _on_hitbox_body_entered(body: Node,) -> void:
	if body.is_in_group("enemies"):
		print ("player hit enemy")
		if body.has_method("hit"):
			var dir = (body.global_position - global_position).normalized()
			body.hit(dir,attack_damage)



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		attacking = false
		hitbox.monitoring = false
	if anim_name == "test_attack":
		attacking2 = false
		hitbox.monitoring = false
	if anim_name == "hurt":
		state = FLOOR
	if anim_name == "die":
		await get_tree().create_timer(2).timeout
		get_tree().reload_current_scene()
	if anim_name == "air_attack":
		attacking = false
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_player.animation == "die":
		anim_player.frame = anim_player.sprite_frames.get_frame_count("die") - 2
	
