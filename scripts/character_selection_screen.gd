extends Control
class_name CharacterSelectionScreen

@export var title_screen: String
@export var combat_screen: String

var _should_go_to_combat: bool
var _to_combat_delay: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharacterGrid.choice_hovered.connect(_on_choice_hovered)
	$CharacterGrid.choice_clicked.connect(_on_choice_clicked)

func _process(_delta: float) -> void:
	if _should_go_to_combat:
		_to_combat_delay += _delta
		if _to_combat_delay >= 0.01:
			# needs a delay in order to show a loading screen
			get_tree().change_scene_to_file(combat_screen)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if GameConfig.game_mode == GameConfig.GameMode.CLASSIC:
			if GameConfig.player2_characters != []:
				GameConfig.player2_characters[0].white_out()
				GameConfig.player2_characters = []
				$Player2Texture.texture = null
				$GoButton.visible = false
			elif GameConfig.player1_characters != []:
				GameConfig.player1_characters[0].white_out()
				GameConfig.player1_characters = []
				$Player1Texture.texture = null
				$Player2Texture.texture = null
			else:
				get_tree().change_scene_to_file(title_screen)
	if Input.is_action_just_pressed("ui_accept"):
		if GameConfig.game_mode == GameConfig.GameMode.CLASSIC and GameConfig.player2_characters != []:
			$LoadingScreen.visible = true
			_should_go_to_combat = true

func _on_choice_hovered(choice: CharacterChoice) -> void:
	if GameConfig.game_mode == GameConfig.GameMode.CLASSIC:
		if GameConfig.player1_characters == []:
			$Player1Texture.texture = choice.portrait
		elif GameConfig.player2_characters == []:
			$Player2Texture.texture = choice.portrait

# TODO: only classic mode is supported now
func _on_choice_clicked(choice: CharacterChoice) -> void:
	if GameConfig.game_mode == GameConfig.GameMode.CLASSIC:
		if GameConfig.player1_characters == []:
			GameConfig.player1_characters = [choice.duplicate()]
			$Player1Texture.texture = choice.portrait
			RcpNode.transmit("send_message", {
				"event_name": "E_CHAR_SELECT",
				"character_name": choice.name,
				"player": 1
			})
			
		elif GameConfig.player2_characters == []:
			GameConfig.player2_characters = [choice.duplicate()]
			$Player2Texture.texture = choice.portrait
			$GoButton.visible = true
			RcpNode.transmit("send_message", {
				"event_name": "E_CHAR_SELECT",
				"character_name": choice.name,
				"player": 2
			})

# Validate GameConfig, move on to combat scene
func _on_go_button_pressed() -> void:
	$LoadingScreen.visible = true
	_should_go_to_combat = true
