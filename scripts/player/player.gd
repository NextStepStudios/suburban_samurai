# player.gd
class_name Player
extends CharacterBody2D

@onready var control_anim: AnimatedSprite2D = $Camera2D/CanvasLayer/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var hitbox: Area2D = $hitbox

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
#contants for health
const HEALTH_LAYER: float = 100.0

# Constants for movement
const SPEED: int = 300
const JUMP_VELOCITY = -450
var attacking: bool = false
var attacking2: bool = false
#preloaded graity from gadot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Input.get_axis("left", "right")
var hitbox_base_offset: Vector2
var attack_damage: int = 0
func _ready():
		
		hitbox_base_offset = hitbox.position  # store initial offset
func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	#if not attacking:	
		#hitbox.monitoring = false
	#if not attacking2:	
		#hitbox.monitoring = false
	#Movement code
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# add gravity
	if  not is_on_floor():
		velocity += get_gravity() * delta
		#jump code
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	
	#play animation logic
	if attacking:
		animation_player.play("attack")
	elif attacking2:
		animation_player.play("attack2")
	else:
		if is_on_floor():
			if direction  == 0:
				anim_player.play("idle")
			else:
				anim_player.play("run")
		else:
			if Input.is_action_pressed("jump"):
				anim_player.play("jump")
	
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
		
	move_and_slide()
	
		




func _is_attacking():
	attacking = true
	attack_damage = 10
func _is_attacking2():
	attacking2 = true
	attack_damage = 20
	#hitbox.monitoring = true
	#
	#await get_tree().create_timer(0.8).timeout
	#
	#hitbox.monitoring = false
	#print("hitbox off")
	#attacking = false

	
#func _on_frame_changed():
	#if anim_player.animation == "Attack":
		## enable hitbox on frames 2 and 3
		#if anim_player.frame in [13, 14,15,16,17,18]:
			#hitbox.monitoring = true
		#else:
			#hitbox.monitoring = false
	#else:
		#hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node, attack_damage: int = 10) -> void:
	print ("colision")
	if body.is_in_group("enemies"):
		print ("player hit enemy")
		if body.has_method("hit"):
			var dir = (body.global_position - global_position).normalized()
			body.hit(dir,attack_damage)


func _on_animated_sprite_2d_frame_changed() -> void:
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		attacking = false
	if anim_name == "attack2":
		attacking2 = false
