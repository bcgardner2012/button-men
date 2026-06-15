extends ColorRect
class_name BreathingButton

@export var from_color: Color
@export var to_color: Color
@export var default_color: Color
@export var animation_time: float

var _color_diff: Color
var _current_color: Color
var _descend: bool
var _hovered: bool
var _timer: float

func _ready() -> void:
	_current_color = default_color
	color = _current_color
	_color_diff = to_color - from_color

func _process(delta: float) -> void:
	if _hovered:
		_timer += delta
		var mult = _timer / animation_time
		if _descend:
			color = to_color - (_color_diff * mult)
		else:
			color = from_color + (_color_diff * mult)
		
		# we changed directions, we should also reset the timer
		if mult >= 1.0:
			_descend = not _descend
			_timer = 0.0

func _on_mouse_entered() -> void:
	_hovered = true
	_timer = 0.0


func _on_mouse_exited() -> void:
	_hovered = false
	color = default_color
	_descend = false
