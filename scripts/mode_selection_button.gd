extends BreathingButton
class_name ModeSelectionButton

@export var mode: GameConfig.GameMode
@export var character_selection_scene: String

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		GameConfig.game_mode = mode
		get_tree().change_scene_to_file(character_selection_scene)
