extends CharacterSelectionStrategy
class_name ClassicTagCharacterSelectionStrategy

func on_ui_cancel( \
	p1_textures: Array[Node], \
	p2_textures: Array[Node], \
	go_button: Control, \
	title_screen: String \
) -> void:
	if GameConfig.player2_characters != []:
		GameConfig.player2_characters.pop_back()
		p2_textures[GameConfig.player2_characters.size()].texture = null
		go_button.visible = false
	elif GameConfig.player1_characters != []:
		GameConfig.player1_characters.pop_back()
		p1_textures[GameConfig.player1_characters.size()].texture = null
	else:
		get_tree().change_scene_to_file(title_screen)
	
	RcpNode.transmit("send_message", {
		"event_name": "E_CHAR_REMOVE"
	})

# return true if conditions are met for starting a game in the selected GameMode
func on_ui_accept() -> bool:
	return GameConfig.player2_characters.size() == 2

func on_choice_hovered( \
	choice: CharacterChoice, \
	p1_textures: Array[Node], \
	p2_textures: Array[Node] \
) -> void:
	if GameConfig.player1_characters.size() < 2:
		p1_textures[GameConfig.player1_characters.size()].texture = choice.portrait
	elif GameConfig.player2_characters.size() < 2:
		p2_textures[GameConfig.player2_characters.size()].texture = choice.portrait

func on_choice_clicked( \
	choice: CharacterChoice, \
	p1_textures: Array[Node], \
	p2_textures: Array[Node], \
	go_button: Control \
) -> void:
	if GameConfig.player1_characters.size() < 2:
		p1_textures[GameConfig.player1_characters.size()].texture = choice.portrait
		GameConfig.player1_characters.append(choice.duplicate())
		RcpNode.transmit("send_message", {
			"event_name": "E_CHAR_SELECT",
			"character_name": choice.name,
			"player": 1
		})
		
	elif GameConfig.player2_characters.size() < 2:
		p2_textures[GameConfig.player2_characters.size()].texture = choice.portrait
		GameConfig.player2_characters.append(choice.duplicate())
		RcpNode.transmit("send_message", {
			"event_name": "E_CHAR_SELECT",
			"character_name": choice.name,
			"player": 2
		})
	
	if GameConfig.player2_characters.size() == 2:
		go_button.visible = true
