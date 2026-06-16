extends Control
class_name CombatScreen

enum State {
	NONE, # initial state and holds the UI in place while the player selects swing dice
	SETUP, 
	INITIATIVE,
	P1_TURN,
	P2_TURN, # determine possible moves and queue one
	P2_TURN_TELEGRAPH, # draw lines to demonstrate the queued move, hold for some time
	P2_TURN_EXECUTE, # execute queued move and cleanup
	ROUND_END,
	GAME_END,
	FATAL_ERROR
}

const AI_DIE_INDEX = 0
const HUMAN_DIE_INDEX = 2
const DIE_SIZES = ["4", "6", "8", "12", "20"]

@export var game_over_screen: String

# SETUP variables
var _pending_swing_dice_count: int
var _tag_swing_dice_count: int # stores the amount of swing dice a tag character has

# General TURN logic variables
var _p1_dice_lost: int
var _p2_dice_lost: int
var _skip_count: int
var _active_p1_dice: Control
var _active_p2_dice: Control
var _inactive_p1_dice: Control
var _inactive_p2_dice: Control
var _p1_index: int
var _p2_index: int

# AI Telegraphing variables
var _telegraphing: bool
const TELEGRAPH_TIME = 1.5 # seconds
var _telegraph_timer: float

# Round End variables
var _p1_win_count: int
var _p2_win_count: int

static var die_mappings: Dictionary = {
	"4": preload("res://scenes/dice/d4/normal_d_4.tscn"),
	"4S": preload("res://scenes/dice/d4/shadow_d_4.tscn"),
	"4P": preload("res://scenes/dice/d4/poison_d_4.tscn"),
	"4R": preload("res://scenes/dice/d4/rush_d_4.tscn"),
	"6": preload("res://scenes/dice/d6/normal_d_6.tscn"),
	"6S": preload("res://scenes/dice/d6/shadow_d_6.tscn"),
	"6P": preload("res://scenes/dice/d6/poison_d_6.tscn"),
	"6R": preload("res://scenes/dice/d6/rush_d_6.tscn"),
	"8": preload("res://scenes/dice/d8/normal_d_8.tscn"),
	"8S": preload("res://scenes/dice/d8/shadow_d_8.tscn"),
	"8P": preload("res://scenes/dice/d8/poison_d_8.tscn"),
	"8R": preload("res://scenes/dice/d8/rush_d_8.tscn"),
	"12": preload("res://scenes/dice/d12/normal_d_12.tscn"),
	"12S": preload("res://scenes/dice/d12/shadow_d_12.tscn"),
	"12P": preload("res://scenes/dice/d12/poison_d_12.tscn"),
	"12R": preload("res://scenes/dice/d12/rush_d_12.tscn"),
	"20": preload("res://scenes/dice/d20/normal_d_20.tscn"),
	"20S": preload("res://scenes/dice/d20/shadow_d_20.tscn"),
	"20P": preload("res://scenes/dice/d20/poison_d_20.tscn"),
	"20R": preload("res://scenes/dice/d20/rush_d_20.tscn"),
	"X": preload("res://scenes/dice/dx/normal_d_x.tscn"),
	"XS": preload("res://scenes/dice/dx/shadow_d_x.tscn"),
	"XP": preload("res://scenes/dice/dx/poison_d_x.tscn"),
	"XR": preload("res://scenes/dice/dx/rush_d_x.tscn")
}

var _state: State = State.NONE

func _ready() -> void:
	_round_setup()

func _round_setup() -> void:
	$Player1Texture.texture = GameConfig.player1_characters[0].portrait
	$Player2Texture.texture = GameConfig.player2_characters[0].portrait
	
	_pending_swing_dice_count = _round_setup_player1(GameConfig.player1_characters[0], $Player1Dice)
	if GameConfig.player1_characters.size() > 1:
		_tag_swing_dice_count = _round_setup_player1(GameConfig.player1_characters[1], $Tag1Dice)
	
	_round_setup_player2(GameConfig.player2_characters[0], $Player2Dice)
	if GameConfig.player2_characters.size() > 1:
		_round_setup_player2(GameConfig.player2_characters[1], $Tag2Dice)

# returns number of dice this character needs to set
func _round_setup_player1(character: CharacterChoice, dice_node: Control) -> int:
	var i = 0
	var swing_dice_count = 0
	for die_code in character.dice:
		var die = die_mappings.get(die_code).instantiate() as Die
		die.player = 1
		
		var slot = dice_node.get_child(i) as CombatDieSlot
		slot.add_child(die)
		if die.textures.size() == 1: # X
			slot.show_arrows()
			swing_dice_count += 1
			$Buttons/ConfirmButton.visible = true
			$Buttons/ConfirmButton.disabled = true
		i += 1
	return swing_dice_count

func _round_setup_player2(character: CharacterChoice, dice_node: Control) -> void:
	var i = 0
	for die_code in character.dice:
		var die = die_mappings.get(die_code).instantiate() as Die
		die.player = 2
		
		var slot = dice_node.get_child(i) as CombatDieSlot
		slot.add_child(die)
		#if die.textures.size() == 1: # X
		#	pass # In classic, P2 is AI, randomly choose
		i += 1

func _new_round_cleanup() -> void:
	_free_dice_slots($Player1Dice)
	_free_dice_slots($Player2Dice)
	if GameConfig.game_mode == GameConfig.GameMode.CLASSIC_TAG:
		_free_dice_slots($Tag1Dice)
		_free_dice_slots($Tag2Dice)
	
	_p1_dice_lost = 0
	_p2_dice_lost = 0
	_skip_count = 0
	_p1_index = 0
	_p2_index = 0
	_active_p1_dice = $Player1Dice
	_active_p2_dice = $Player2Dice
	_inactive_p1_dice = $Tag1Dice
	_inactive_p2_dice = $Tag2Dice
	$Player1Dice.visible = true
	$Tag1Dice.visible = false
	$Player2Dice.visible = true
	$Tag2Dice.visible = false

func _free_dice_slots(dice_node: Control) -> void:
	for child in dice_node.get_children():
		var slot = child as CombatDieSlot
		slot.get_die().free()

func _process(_delta: float) -> void:
	match _state:
		State.SETUP:
			print("SETUP")
			_new_round_cleanup()
			_round_setup()
			_state = State.NONE
		State.INITIATIVE:
			print("INITIATIVE")
			var _active_player = _do_initiative_rolls()
			if _active_player == 1:
				_set_state_p1_turn() # turn on targeting-drawing and die clicks
			elif _active_player == 2:
				_state = State.P2_TURN
			else:
				print_debug("Initiative state logic is broken, no player is active")
				_state = State.FATAL_ERROR
		# State.P1_TURN: # driven by the player, use signals
		State.P2_TURN:
			print("P2_TURN")
			# identify possible moves, v1: select the one that immediately grants most points
			$AITurnManager.determine_possible_moves(_active_p1_dice, _active_p2_dice)
			if $AITurnManager.possible_moves.size() > 0:
				# first entry takes the largest die possible, PMs sorted in order of die score
				$AITurnManager.set_chosen_move(0)
				_state = State.P2_TURN_TELEGRAPH
			else:
				# skip or tag
				if not MoveHelper.is_defeated(_inactive_p2_dice):
					_ai_tag_out()
				else:
					_skip_count += 1
					if _skip_count >= 2:
						_state = State.ROUND_END
					else:
						_set_state_p1_turn()
		
		State.P2_TURN_TELEGRAPH:
			if not _telegraphing:
				print("P2_TURN_TELEGRAPH")
				$AITurnManager.draw_chosen_move()
				_telegraphing = true
			else:
				_telegraph_timer += _delta
				if _telegraph_timer >= TELEGRAPH_TIME:
					_state = State.P2_TURN_EXECUTE
		
		State.P2_TURN_EXECUTE:
			print("P2_TURN_EXECUTE")
			if $AITurnManager.chosen_move == null:
				# skip
				_skip_count += 1
				if _skip_count >= 2:
					_state = State.ROUND_END
				else:
					_set_state_p1_turn()
			else:
				_skip_count = 0
				_p1_dice_lost += $AITurnManager.chosen_move.inactive_player_dice.size()
				$AITurnManager.execute_chosen_move()
				_set_state_p1_turn()
			# cleanup AI vars
			_telegraphing = false
			_telegraph_timer = 0.0
		
		State.ROUND_END:
			print("Ending the round")
			# get scores to determine winner
			var p1_score = _get_score([$Player1Dice, $Tag1Dice], [$Player2Dice, $Tag2Dice])
			var p2_score = _get_score([$Player2Dice, $Tag2Dice], [$Player1Dice, $Tag1Dice])
			print("p1 " + str(p1_score))
			print("p2 " + str(p2_score))
			if p1_score > p2_score:
				$Player2Texture/Health.get_child(0).queue_free()
				_p1_win_count += 1
				RcpNode.transmit("send_message", {
					"event_name": "round_end",
					"winner": 1
				})
			elif p1_score < p2_score:
				$Player1Texture/Health.get_child(0).queue_free()
				_p2_win_count += 1
				RcpNode.transmit("send_message", {
					"event_name": "round_end",
					"winner": 2
				})
			# tie? Another round
			
			if _p1_win_count >= 3 or _p2_win_count >= 3:
				_state = State.GAME_END
			else:
				_state = State.SETUP
		
		State.GAME_END:
			print("GAME END")
			if _p1_win_count >= 3:
				GameConfig.winner = 1
			else:
				GameConfig.winner = 2
			
			RcpNode.transmit("send_message", {
				"event_name": "game_end",
				"winner": GameConfig.winner
			})
			
			get_tree().change_scene_to_file(game_over_screen)

func _get_score(my_dice: Array[Control], other_dice: Array[Control]) -> float:
	var score: float = 0.0
	for ctrl in my_dice:
		for child in ctrl.get_children():
			var slot = child as CombatDieSlot
			var die = slot.get_die()
			if die.visible:
				if die.type == Die.Type.POISON:
					score -= die.textures.size()
				else:
					score += die.textures.size() * 0.5
	for ctrl in other_dice:
		for child in ctrl.get_children():
			var slot = child as CombatDieSlot
			var die = slot.get_die()
			if not die.visible:
				if die.type == Die.Type.POISON:
					score -= die.textures.size() * 0.5
				else:
					score += die.textures.size()
	return score

# confirm button should be pressed by player 1 once per character in party
var _confirmation_count = 0
func _on_confirm_button_pressed() -> void:
	_confirmation_count += 1
	
	if _confirmation_count == 1:
		for child in $Player1Dice.get_children():
			(child as CombatDieSlot).hide_arrows()
		if GameConfig.player1_characters.size() > 1:
			# prep Tag1Dice for selection, and values to ensure all swing dice are set
			$Tag1Dice.visible = true
			$Player1Dice.visible = false
			_pending_swing_dice_count = _tag_swing_dice_count
			_tag_swing_dice_count = 0
			$Buttons/ConfirmButton.disabled = true
			$Player1Texture.texture = GameConfig.player1_characters[1].portrait
		
	elif _confirmation_count == 2:
		for child in $Tag1Dice.get_children():
			(child as CombatDieSlot).hide_arrows()
		
		$Player1Texture.texture = GameConfig.player1_characters[0].portrait
		$Tag1Dice.visible = false
		$Player1Dice.visible = true
	
	if _confirmation_count == GameConfig.player1_characters.size():
		$Buttons/ConfirmButton.disabled = true
		$Buttons/ConfirmButton.visible = false
	
		# set NPC swing dice
		_confirm_ai_dice($Player2Dice)
		if GameConfig.player2_characters.size() > 1:
			_confirm_ai_dice($Tag2Dice)
	
		# Jumping straight into initiative logic doesn't allow time for newly created dice to initialize
		# Set state and let _process be the driver for state logic.
		_state = State.INITIATIVE
		_confirmation_count = 0
		_active_p1_dice = $Player1Dice
		_active_p2_dice = $Player2Dice
		_inactive_p1_dice = $Tag1Dice
		_inactive_p2_dice = $Tag2Dice
		_make_dice_clickable()

func _confirm_ai_dice(dice_node: Control) -> void:
	for child in dice_node.get_children():
		var slot = child as CombatDieSlot
		var die = slot.get_child(AI_DIE_INDEX) as Die
		if die.textures.size() == 1: # X
			var random_size = DIE_SIZES[randi() % DIE_SIZES.size()]
			var die_code = random_size + slot.get_suffix(die)
			var new_die = die_mappings[die_code].instantiate() as Die
			new_die.player = 2
			die.free() # queue_free was causing a race-condition, sometimes dx wouldn't be gone before Initiative checks
			slot.add_child(new_die)

func _make_dice_clickable() -> void:
	for child in $Player1Dice.get_children():
		var d = child.get_child(HUMAN_DIE_INDEX) as Die
		d.clicked.connect($HumanTurnManager.on_die_clicked)
	for child in $Player2Dice.get_children():
		var d = child.get_child(AI_DIE_INDEX) as Die
		d.clicked.connect($HumanTurnManager.on_die_clicked)
	for child in $Tag1Dice.get_children():
		var d = child.get_child(HUMAN_DIE_INDEX) as Die
		d.clicked.connect($HumanTurnManager.on_die_clicked)
	for child in $Tag2Dice.get_children():
		var d = child.get_child(AI_DIE_INDEX) as Die
		d.clicked.connect($HumanTurnManager.on_die_clicked)

func _do_initiative_rolls() -> int:
	var winner = 0
	while (winner == 0):
		var lowest_p1_roll = 99
		var lowest_p2_roll = 99
		for child in $Player1Dice.get_children():
			var d = child.get_child(HUMAN_DIE_INDEX) as Die
			d.roll()
			lowest_p1_roll = mini(lowest_p1_roll, d.value)
			
		for child in $Player2Dice.get_children():
			var d = child.get_child(AI_DIE_INDEX) as Die
			d.roll()
			lowest_p2_roll = mini(lowest_p2_roll, d.value)
		
		if lowest_p1_roll < lowest_p2_roll:
			winner = 1
		elif lowest_p1_roll > lowest_p2_roll:
			winner = 2
		# else, winner remains 0, reroll dice
	return winner

func _on_slot_swing_die_set() -> void:
	_pending_swing_dice_count -= 1
	if _pending_swing_dice_count <= 0:
		$Buttons/ConfirmButton.disabled = false

func _on_human_turn_manager_attacked(selected_p1_dice: Array[Die], selected_p2_dice: Array[Die]) -> void:
	for die in selected_p1_dice:
		die.roll()
	_p2_dice_lost += selected_p2_dice.size()
	if _p2_dice_lost >= 5 * GameConfig.player2_characters.size():
		_state = State.ROUND_END
	else:
		_state = State.P2_TURN
	
	_skip_count = 0
	$HumanTurnManager.disable()


func _on_human_turn_manager_skipped() -> void:
	_skip_count += 1
	if _skip_count >= 2:
		_state = State.ROUND_END
	else:
		_state = State.P2_TURN
	$HumanTurnManager.disable()


func _on_human_turn_manager_tag_out() -> void:
	# swap active dice
	var tmp = _inactive_p1_dice
	_inactive_p1_dice = _active_p1_dice
	_active_p1_dice = tmp
	
	# show active
	_active_p1_dice.visible = true
	_inactive_p1_dice.visible = false
	_reroll_dice(_active_p1_dice)
	
	# show corresponding image
	_p1_index += 1
	_p1_index %= 2
	$Player1Texture.texture = GameConfig.player1_characters[_p1_index].portrait

	# turn over
	_skip_count = 0
	$HumanTurnManager.disable()
	_state = State.P2_TURN

func _ai_tag_out() -> void:
	# swap active dice
	var tmp = _inactive_p2_dice
	_inactive_p2_dice = _active_p2_dice
	_active_p2_dice = tmp
	
	# show active
	_active_p2_dice.visible = true
	_inactive_p2_dice.visible = false
	_reroll_dice(_active_p2_dice)
	
	# show corresponding image
	_p2_index += 1
	_p2_index %= 2
	$Player2Texture.texture = GameConfig.player2_characters[_p2_index].portrait
	
	RcpNode.transmit("send_message", {
		"event_name": "tag",
		"player": 2
	})
	
	# turn over
	_set_state_p1_turn()

func _reroll_dice(dice: Control) -> void:
	for child in dice.get_children():
		var slot = child as CombatDieSlot
		var die = slot.get_die()
		if die != null:
			die.roll()

func _set_state_p1_turn() -> void:
	_state = State.P1_TURN
	$HumanTurnManager.enable(_active_p1_dice, _active_p2_dice, _inactive_p1_dice)
