# player.gd

extends CharacterBody2D

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D


# Constants for movement
const SPEED: int = 300
const JUMP_VELOCITY = -450
var attacking: bool = false
#preloaded graity from gadot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta: float) -> void:
	
	
	#Movement code
	var direction = Input.get_axis("left", "right")
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
	elif direction < 0:
		anim_player.flip_h = true

	if Input.is_action_pressed("attack"):
		_is_attacking()
		if attacking:
			anim_player.play("attack1")
			move_and_slide()
		
		#await get_tree().create_timer(0.5).timeout
		#attacking = false

	move_and_slide()
func _is_attacking():
	attacking = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	attacking = false 
