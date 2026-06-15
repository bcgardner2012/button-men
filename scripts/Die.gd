extends TextureRect
class_name Die

signal clicked(die: Die) # passes self

enum Type {
	NORMAL,
	SHADOW,
	POISON,
	RUSH
}

@export var textures: Array[Texture2D]
@export var type: Type
var value: int
var player: int # 1 or 2

func roll() -> int:
	var r = randi() % textures.size()
	value = r + 1
	texture = textures[r]
	return value

func _enter_tree() -> void:
	gui_input.connect(_on_gui_input)

# left click to select, again to deselect
func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		clicked.emit(self)
