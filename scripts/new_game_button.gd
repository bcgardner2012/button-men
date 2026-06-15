extends BreathingButton
class_name NewGameButton

@export var submenu: Control


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		submenu.visible = true
		get_parent().visible = false
