extends RefCounted
class_name PossibleMove

# Data structure to help analyze what moves an AI can make, and whether the player
# can skip turn due to having no valid moves.

enum AttackType {
	INVALID,
	POWER,
	SKILL,
	SHADOW,
	RUSH
}

var active_player_dice: Array[Die]
var inactive_player_dice: Array[Die]
var attack_type: AttackType

func _init(_active: Array[Die], _inactive: Array[Die], _type: AttackType) -> void:
	active_player_dice = _active
	inactive_player_dice = _inactive
	attack_type = _type
