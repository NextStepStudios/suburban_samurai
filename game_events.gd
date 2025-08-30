# game_events.gd
extends Node

# global signals
@warning_ignore("unused_signal") # ignore warning
signal deal_dmg_to_player(dmg) # player takes damage
@warning_ignore("unused_signal") # ignore warning
signal health_change_player(new_hp) # player gets ui hp update
@warning_ignore("unused_signal") # ignore warning
signal player_died # player dies
@warning_ignore("unused_signal")
signal level_finished # triggers level switch
@warning_ignore("unused_signal")
signal deal_dmg_to_mob(dmg)
@warning_ignore("unused_signal")
signal health_change_mob(new_hp)

# global vars
var current_score: int = 0
var current_health: int = PLAYER_MAX_HP
var current_enemy_health = ENEMY_MAX_HP
# global constants
# player
const PLAYER_MAX_HP: int = 6

# enemy
const ENEMY_MAX_HP: int = 6
