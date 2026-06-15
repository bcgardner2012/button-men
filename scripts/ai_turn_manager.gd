extends Control
class_name AITurnManager

# AI is always Player 2

@export var p1_dice: Control
@export var p2_dice: Control

var possible_moves: Array[PossibleMove]
var chosen_move: PossibleMove

func execute_chosen_move() -> void:
	# reroll AI dice
	for die in chosen_move.active_player_dice:
		die.roll()
	
	# hide human dice
	for die in chosen_move.inactive_player_dice:
		die.visible = false
	
	RcpNode.transmit("send_message", {
		"event_name": "attack",
		"attack_type": chosen_move.attack_type,
		"player": 2
	})
	
	chosen_move = null
	possible_moves = []
	queue_redraw()

func set_chosen_move(index: int) -> void:
	chosen_move = possible_moves[index]
	match chosen_move.attack_type:
		PossibleMove.AttackType.POWER:
			color = Color.WHITE_SMOKE
		PossibleMove.AttackType.SKILL:
			color = Color.WHITE_SMOKE
		PossibleMove.AttackType.SHADOW:
			color = Color.DARK_BLUE
		PossibleMove.AttackType.RUSH:
			color = Color.DARK_ORANGE

func draw_chosen_move() -> void:
	if chosen_move != null:
		queue_redraw()

func determine_possible_moves() -> void:
	possible_moves = MoveHelper.determine_possible_moves(p2_dice, p1_dice)

###########################

var width : int = 10
var color : Color = Color.WHITE_SMOKE 

func _draw():
	if chosen_move == null:
		return
	for p1_die in chosen_move.inactive_player_dice:
		for p2_die in chosen_move.active_player_dice:
			var point1 = p1_die.get_screen_position() + (p1_die.size / 2)
			var point2 = p2_die.get_screen_position() + (p2_die.size / 2)
			draw_line(point1, point2, color, width)
