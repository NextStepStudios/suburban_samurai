# main.gd
extends Node

# preload UI scenes
const MAIN_MENU = preload("res://scenes/ui/main_menu.tscn")
const PAUSE_MENU = preload("res://scenes/ui/pause_menu.tscn")

# levels
var level_scenes = [
	"res://scenes/levels/level_1.tscn" # index 0
]
var current_level_index = 0 # start at fisrt 
var current_level_instance # track curr scene

# init func
func _ready():
	randomize() # random seed
	print("Game has started")
	GameEvents.current_score = 0 # reset on new game
	GameEvents.current_health = GameEvents.PLAYER_MAX_HP # update
	
	GameEvents.level_finished.connect(on_level_finished) # listen for level finish
	load_level() # load next level

func _unhandled_input(event):
	pass
	# TODO: add pause system
	
func load_level():
	# clear curr level
	if is_instance_valid(current_level_instance):
		current_level_instance.queue_free() # delete it
		
	var level_path = level_scenes[current_level_index] # get level path via index
	var level_scene = load(level_path) # load the level at path
	
	current_level_instance = level_scene.instantiate() # create new level
	add_child(current_level_instance) # add new level as child
	
func on_level_finished():
	current_level_index += 1 # incr level
	
	# check if last level
	if current_level_index < level_scenes.size():
		load_level()
	else: # otherwise end of game
		get_tree().change_scene_to_packed(MAIN_MENU)
