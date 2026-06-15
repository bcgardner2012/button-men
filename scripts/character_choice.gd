extends Control
class_name CharacterChoice

signal hovered(choice: CharacterChoice)
signal clicked(choice: CharacterChoice)

@export var character_name: String
@export var texture: Texture2D
@export var portrait: Texture2D
@export var dice: Array[String]

var _disabled: bool

func _ready() -> void:
	$TextureRect.texture = texture


func _on_texture_rect_mouse_entered() -> void:
	if not _disabled:
		hovered.emit(self)


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event) and not _disabled:
		clicked.emit(self)

func gray_out() -> void:
	modulate = Color("575757")
	_disabled = true

func white_out() -> void:
	modulate = Color("FFFFFF")
	_disabled = false
