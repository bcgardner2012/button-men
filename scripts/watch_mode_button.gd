extends BreathingButton
class_name WatchModeButton

@export var submenu: Control

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		GameConfig.is_watch_mode = true
		submenu.visible = true
		get_parent().visible = false
