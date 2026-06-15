extends Control
class_name GameOverScreen

@export var title_screen: String

const TIME = 3.0 # seconds
var _timer: float

func _ready() -> void:
	if GameConfig.winner == 1:
		$PlayerTexture.texture = GameConfig.player1_characters[0].portrait
	else:
		$PlayerTexture.texture = GameConfig.player2_characters[0].portrait

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= TIME:
		_cleanup_statics()
		get_tree().change_scene_to_file(title_screen)

func _cleanup_statics() -> void:
	GameConfig.player1_characters = []
	GameConfig.player2_characters = []
