extends Node2D

@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var attack_frames: Array = [
	preload("res://assets/player/animations/Sammy Short Attack/SamSattack00.png"),
	preload("res://assets/player/animations/Sammy Short Attack/SamSattack01.png"),
	preload("res://assets/player/animations/Sammy Short Attack/SamSattack02.png")
	# add all frames...
]

func _ready():
	if animation_player == null:
		push_error("AnimationPlayer not found")
		return
	if sprite == null:
		push_error("Sprite2D not found")
		return

	add_frames_to_animation("Attack", attack_frames, 10)
	animation_player.play("Attack")  # play immediately to test

func add_frames_to_animation(animation_name: String, sprite_frames: Array, fps: int = 10):
	var anim: Animation = animation_player.get_animation(animation_name)
	if anim == null:
		anim = Animation.new()
		# **Godot 4 correct way to add an animation:**
		animation_player.add_animation(animation_name, anim) if "add_animation" in animation_player else animation_player.add_animation_override(animation_name, anim)

	var dt = 1.0 / fps

	if anim.get_track_count() == 0:
		anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(0, str(sprite.get_path()) + ":texture")

	for i in range(sprite_frames.size()):
		anim.track_insert_key(0, i * dt, sprite_frames[i])
