extends Control

const MAIN_SCENE_PATH = "res://main.tscn"
@onready var play_button: TextureButton = $HBoxContainer/PlayButton
@onready var quit_button: TextureButton = $HBoxContainer/QuitButton

func _ready():
	$HBoxContainer/PlayButton.grab_focus()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

func _on_play_button_pressed() -> void:
	# tell scene tree to switch from menu to main game scene
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit() # safe exit of application
