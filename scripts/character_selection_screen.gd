extends Control
class_name CharacterSelectionScreen

@export var title_screen: String
@export var combat_screen: String

var _strategy: CharacterSelectionStrategy

var _should_go_to_combat: bool
var _to_combat_delay: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharacterGrid.choice_hovered.connect(_on_choice_hovered)
	$CharacterGrid.choice_clicked.connect(_on_choice_clicked)
	
	match GameConfig.game_mode:
		GameConfig.GameMode.CLASSIC:
			_strategy = $Strategies/ClassicStrategy
		GameConfig.GameMode.CLASSIC_TAG:
			_strategy = $Strategies/ClassicTagStrategy

func _process(_delta: float) -> void:
	if _should_go_to_combat:
		_to_combat_delay += _delta
		if _to_combat_delay >= 0.01:
			# needs a delay in order to show a loading screen
			get_tree().change_scene_to_file(combat_screen)
	
	if Input.is_action_just_pressed("ui_cancel"):
		_strategy.on_ui_cancel($Player1Textures.get_children(), $Player2Textures.get_children(), $GoButton, title_screen)
	if Input.is_action_just_pressed("ui_accept"):
		var should_load_next_scene = _strategy.on_ui_accept()
		$LoadingScreen.visible = should_load_next_scene
		_should_go_to_combat = should_load_next_scene

func _on_choice_hovered(choice: CharacterChoice) -> void:
	_strategy.on_choice_hovered(choice, $Player1Textures.get_children(), $Player2Textures.get_children())

func _on_choice_clicked(choice: CharacterChoice) -> void:
	_strategy.on_choice_clicked(choice, $Player1Textures.get_children(), $Player2Textures.get_children(), $GoButton)

# Validate GameConfig, move on to combat scene
func _on_go_button_pressed() -> void:
	$LoadingScreen.visible = true
	_should_go_to_combat = true
