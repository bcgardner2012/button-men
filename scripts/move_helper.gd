extends Node
class_name MoveHelper

static func has_possible_move(active_dice: Control, inactive_dice: Control) -> bool:
	var moves = determine_possible_moves(active_dice, inactive_dice, true)
	return moves.size() > 0

# first_only adds break functionality to perform a has_possible_move check, rather than fetching all of them
static func determine_possible_moves(active_dice: Control, inactive_dice: Control, first_only: bool = false) -> Array[PossibleMove]:
	var possible_moves: Array[PossibleMove]
	
	# go over all remaining enemy dice. Check if there are any possible
	# combos that result in another die being captured.
	var remaining_inactive_dice = _get_remaining_dice(inactive_dice)
	remaining_inactive_dice.sort_custom(_compare_die_sizes)
	var remaining_active_dice = _get_remaining_dice(active_dice)
	for inactive_die in remaining_inactive_dice:
		for i in range(remaining_active_dice.size()):
			var active_die = remaining_active_dice[i]
			# check for possible POWER_ATTACK
			if active_die.type != Die.Type.SHADOW and active_die.value >= inactive_die.value:
				possible_moves.append(PossibleMove.new([active_die], [inactive_die], PossibleMove.AttackType.POWER))
				if first_only:
					return possible_moves
			# check for possible SHADOW_ATTACK
			if active_die.type == Die.Type.SHADOW and active_die.value <= inactive_die.value and active_die.textures.size() >= inactive_die.textures.size():
				possible_moves.append(PossibleMove.new([active_die], [inactive_die], PossibleMove.AttackType.SHADOW))
				if first_only:
					return possible_moves
		
		# SKILL_ATTACK
		var skill_combos = SkillComboFinder.find(remaining_active_dice, inactive_die.value)
		for combo in skill_combos:
			possible_moves.append(PossibleMove.new(_die_cast_array(combo), [inactive_die], PossibleMove.AttackType.SKILL))
			if first_only:
				return possible_moves
	
	# RUSH_ATTACK
	for active_die in remaining_active_dice:
		var rush_combos = RushComboFinder.find(remaining_inactive_dice, active_die.value)
		for combo in rush_combos:
			if active_die.type == Die.Type.RUSH or _combo_has_rush_die(combo):
				possible_moves.append(PossibleMove.new([active_die], combo, PossibleMove.AttackType.RUSH))
				if first_only:
					return possible_moves
	
	return possible_moves

static func _get_remaining_dice(dice_node: Control) -> Array[Die]:
	var remaining: Array[Die] = []
	for child in dice_node.get_children():
		var slot = child as CombatDieSlot
		var die = slot.get_die()
		if die != null and die.visible:
			remaining.append(die)
	return remaining

static func _compare_die_sizes(a: Die, b: Die) -> bool:
	var val_a = a.textures.size()
	if a.type == Die.Type.POISON:
		val_a *= -1
	var val_b = b.textures.size()
	if b.type == Die.Type.POISON:
		val_b *= -1
	return val_a > val_b

# it is fucking embarassing that Gdscript does not support multi-d typed arrays...
static func _die_cast_array(arr: Array) -> Array[Die]:
	var t: Array[Die] = []
	for d in arr:
		t.append(d)
	return t

static func _combo_has_rush_die(combo: Array[Die]) -> bool:
	for die in combo:
		if die.type == Die.Type.RUSH:
			return true
	return false
