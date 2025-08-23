# player.gd

extends CharacterBody2D

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D


# Constants for movement
const SPEED: int = 300
const JUMP_VELOCITY = -450

#preloaded graity from gadot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta: float) -> void:
	
	
	#Movement code
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if  not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		anim_player.play("idle")
