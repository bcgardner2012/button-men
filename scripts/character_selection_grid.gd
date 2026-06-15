extends Control
class_name CharacterSelectionGrid

signal choice_hovered(choice: CharacterChoice)
signal choice_clicked(choice: CharacterChoice)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in $GridContainer.get_children():
		var choice = child as CharacterChoice
		choice.hovered.connect(_emit_hovered)
		choice.clicked.connect(_emit_clicked)

func _emit_hovered(choice: CharacterChoice) -> void:
	choice_hovered.emit(choice)

func _emit_clicked(choice: CharacterChoice) -> void:
	choice_clicked.emit(choice)
