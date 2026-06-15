extends Control
class_name CombatDieSlot

signal swing_die_set()

const AI_DIE_INDEX = 0
const HUMAN_DIE_INDEX = 2 # die will always be at index 2

@export var player: int
var swing_die_resolved: bool = true

func show_arrows() -> void:
	$LeftArrow.visible = true
	$RightArrow.visible = true
	swing_die_resolved = false

func hide_arrows() -> void:
	$LeftArrow.visible = false
	$RightArrow.visible = false
	swing_die_resolved = true

func _on_left_arrow_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		if not swing_die_resolved:
			swing_die_resolved = true
			swing_die_set.emit()
		var die = get_child(HUMAN_DIE_INDEX) as Die
		var prefix: String = "X"
		match (die.textures.size()):
			1: # X
				prefix = "20"
			4:
				prefix = "20"
			6:
				prefix = "4"
			8:
				prefix = "6"
			12:
				prefix = "8"
			20:
				prefix = "12"
		
		var new_die = CombatScreen.die_mappings.get(prefix + get_suffix(die)).instantiate() as Die
		new_die.player = player
		die.queue_free()
		add_child(new_die)


func _on_right_arrow_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		if not swing_die_resolved:
			swing_die_resolved = true
			swing_die_set.emit()
		var die = get_child(HUMAN_DIE_INDEX) as Die
		var prefix: String = "X"
		match (die.textures.size()):
			1: # X
				prefix = "4"
			4:
				prefix = "6"
			6:
				prefix = "8"
			8:
				prefix = "12"
			12:
				prefix = "20"
			20:
				prefix = "4"
		
		var new_die = CombatScreen.die_mappings.get(prefix + get_suffix(die)).instantiate() as Die
		new_die.player = player
		die.queue_free()
		add_child(new_die)

func get_suffix(die: Die) -> String:
	match die.type:
		Die.Type.NORMAL:
			return ""
		Die.Type.SHADOW:
			return "S"
		Die.Type.POISON:
			return "P"
		Die.Type.RUSH:
			return "R"
	return ""

func get_die() -> Die:
	if player == 1:
		return get_child(HUMAN_DIE_INDEX) as Die
	if player == 2:
		return get_child(AI_DIE_INDEX) as Die
	return null
