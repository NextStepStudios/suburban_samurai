extends Control

const MAIN_SCENE_PATH = "res://main.tscn"


func _on_play_button_pressed() -> void:
	# tell scene tree to switch from menu to main game scene
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit() # safe exit of application
