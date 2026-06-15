extends Node
class_name CharacterSelectionStrategy

# pretend this is an abstract class, do not use or update. Instead, extend this
# and implement these functions

func on_ui_cancel( \
	p1_textures: Array[Node], \
	p2_textures: Array[Node], \
	go_button: Control, \
	title_screen: String \
) -> void:
	pass

# return true if conditions are met for starting a game in the selected GameMode
func on_ui_accept() -> bool:
	return false

func on_choice_hovered( \
	choice: CharacterChoice, \
	p1_textures: Array[Node], \
	p2_textures: Array[Node] \
) -> void:
	pass

func on_choice_clicked( \
	choice: CharacterChoice, \
	p1_textures: Array[Node], \
	p2_textures: Array[Node], \
	go_button: Control \
) -> void:
	pass
