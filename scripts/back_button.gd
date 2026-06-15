extends BreathingButton
class_name BackButton

@export var previous_menu: Control

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		get_parent().visible = false
		if previous_menu != null:
			previous_menu.visible = true
