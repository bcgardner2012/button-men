extends BreathingButton
class_name QuitButton


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		get_tree().quit()
