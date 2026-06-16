extends Control
class_name HumanTurnManager

# emit this before wiping the arrays
signal attacked(selected_p1_dice: Array[Die], selected_p2_dice: Array[Die])
signal skipped()
signal tag_out()

@export var attack_button: Button
@export var clear_button: Button
@export var skip_button: Button
@export var tag_button: Button

const HUMAN_DIE_INDEX = 2

var _enabled: bool = false
var _attack_type: PossibleMove.AttackType = PossibleMove.AttackType.INVALID

# keep track of which dice have been clicked, draw lines from them to the cursor.
# P1 dice are drawn from origin to cursor
var selected_p1_dice: Array[Die]

# Once P2 are selected, draw from P1s to P2s instead of cursor
# When rush dice are involved, enable drawing in both manners
var selected_p2_dice: Array[Die]

# register die.click signals here at runtime
# maybe pass along player number and add each players' dice to their own list.
func on_die_clicked(die: Die) -> void:
	if not _enabled:
		return
	
	if die.player == 1:
		selected_p1_dice.append(die)
	elif die.player == 2:
		selected_p2_dice.append(die)
	
	_attack_type = _determine_attack_type()
	attack_button.disabled = _attack_type == PossibleMove.AttackType.INVALID
	
	queue_redraw()

func enable( \
	_p1_dice: Control, \
	_p2_dice: Control, \
	_inactive_p1_dice: Control \
) -> void:
	_enabled = true
	attack_button.visible = MoveHelper.has_possible_move(_p1_dice, _p2_dice)
	clear_button.visible = attack_button.visible
	if GameConfig.player1_characters.size() <= 1:
		skip_button.visible = not attack_button.visible
		tag_button.visible = false
	else:
		tag_button.visible = not attack_button.visible and not MoveHelper.is_defeated(_inactive_p1_dice)
		skip_button.visible = not attack_button.visible and not tag_button.visible

func disable() -> void:
	_enabled = false
	attack_button.visible = false
	clear_button.visible = false
	skip_button.visible = false
	tag_button.visible = false

######################

var width : int = 10
var color : Color = Color.WHITE_SMOKE 
var _cursor_point : Vector2

func _determine_attack_type() -> PossibleMove.AttackType:
	if _is_one_to_one():
		if _is_valid_shadow_attack():
			color = Color.DARK_BLUE
			return PossibleMove.AttackType.SHADOW
		elif not selected_p1_dice[0].type == Die.Type.SHADOW and selected_p1_dice[0].value >= selected_p2_dice[0].value:
			color = Color.WHITE_SMOKE
			return PossibleMove.AttackType.POWER
	elif _is_many_to_one() and _sum(selected_p1_dice) == selected_p2_dice[0].value:
		color = Color.WHITE_SMOKE
		return PossibleMove.AttackType.SKILL
	elif _is_one_to_two() and _any_are_rush_type() and _sum(selected_p2_dice) == selected_p1_dice[0].value:
		color = Color.DARK_ORANGE
		return PossibleMove.AttackType.RUSH
	color = Color.RED
	return PossibleMove.AttackType.INVALID

func _sum(dice: Array[Die]) -> int:
	var s = 0
	for die in dice:
		s += die.value
	return s

func _is_one_to_one() -> bool:
	return selected_p1_dice.size() == 1 and selected_p2_dice.size() == 1

func _is_many_to_one() -> bool:
	return selected_p1_dice.size() > 1 and selected_p2_dice.size() == 1

func _is_one_to_two() -> bool:
	return selected_p1_dice.size() == 1 and selected_p2_dice.size() == 2

func _is_valid_shadow_attack() -> bool:
	# P1 die must be shadow type
	if selected_p1_dice[0].type != Die.Type.SHADOW:
		return false
	
	# shadow die must be no larger than target
	if selected_p1_dice[0].textures.size() < selected_p2_dice[0].textures.size():
		return false
	
	# shadow dice kill values greater than theirs
	return selected_p1_dice[0].value <= selected_p2_dice[0].value

# rush dice are a double edged sword, enemy can use their ability too
func _any_are_rush_type() -> bool:
	for die in selected_p1_dice:
		if die.type == Die.Type.RUSH:
			return true
	for die in selected_p2_dice:
		if die.type == Die.Type.RUSH:
			return true
	return false

func _process(_delta):
	if not _enabled:
		return
	
	var mouse_position = get_viewport().get_mouse_position()
	if mouse_position != _cursor_point:
		_cursor_point = mouse_position
		queue_redraw()

func _draw():
	for die in selected_p1_dice:
		if selected_p2_dice.size() <= 0:
			var point1 = die.get_screen_position() + (die.size / 2)
			draw_line(point1, _cursor_point, color, width)
		else:
			for target_die in selected_p2_dice:
				var point1 = die.get_screen_position() + (die.size / 2) 
				var point2 = target_die.get_screen_position() + (target_die.size / 2) 
				draw_line(point1, point2, color, width)

func _on_attack_button_pressed() -> void:
	attacked.emit(selected_p1_dice, selected_p2_dice)
	
	RcpNode.transmit("send_message", {
		"event_name": "attack",
		"attack_type": _attack_type,
		"player": 1
	})
	
	selected_p1_dice = []
	for die in selected_p2_dice:
		die.visible = false
	selected_p2_dice = []
	attack_button.disabled = true
	queue_redraw()


func _on_clear_button_pressed() -> void:
	selected_p1_dice = []
	selected_p2_dice = []
	attack_button.disabled = true
	queue_redraw()


func _on_skip_button_pressed() -> void:
	skipped.emit()
	selected_p1_dice = []
	selected_p2_dice = []
	queue_redraw()


func _on_tag_button_pressed() -> void:
	tag_out.emit()
	selected_p1_dice = []
	selected_p2_dice = []
	queue_redraw()
