extends Node


@onready var abutton: AnimatedSprite2D = $"../Abutton"
@onready var bbutton: AnimatedSprite2D = $"../Bbutton"
@onready var analog: AnimatedSprite2D = $"../analog"




func _input(event):
	if event.is_action_pressed("jump", true):
		abutton.play("pressed")
	else:
		abutton.play("default")
	if event.is_action_pressed("attack", true):
		bbutton.play("pressed")
	else:
		bbutton.play("default")
	if event.is_action_pressed("left", true):
		analog.play("left")
	elif event.is_action_pressed("right", true):
		analog.play("right")
	else:
		analog.play("default")
	
