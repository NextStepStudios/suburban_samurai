# game_events.gd
extends Node

# global signals
@warning_ignore("unused_signal") # ignore warning
signal deal_dmg_to_player(dmg)
@warning_ignore("unused_signal") # ignore warning
signal health_change_player(new_hp)
@warning_ignore("unused_signal") # ignore warning
signal player_died

# global vars
var current_score: int = 0
var current_health: int = 0

# global constants
# player
# TODO: add global player consts

# enemy
const ENEMY_NINJA_HP: int = 1
