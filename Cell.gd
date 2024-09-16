extends Control

var _row_idx := 0
var _col_idx := 0

var _neighbor_mine_num := 0
var _is_mine := false
var _is_shown := false
var _is_flag := false

signal click_cell(left_or_right, row, col)

func _ready():
	pass

func _on_ButtonMask_gui_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT or 
				event.button_index == MOUSE_BUTTON_RIGHT) and not event.pressed:
			emit_signal("click_cell", event.button_index == MOUSE_BUTTON_LEFT, _row_idx, _col_idx)
#			print("Left button was clicked at ", row_idx, " ", col_idx)

func set_row_col(row, col):
	_row_idx = row
	_col_idx = col

func add_neighbor_num():
	_neighbor_mine_num += 1
	if _is_mine:
		return
#	$Label.text = str(_neighbor_mine_num)

func set_mine(is_mine: bool):
	_is_mine = is_mine
#	$Label.text = "M"

func is_mine():
	return _is_mine

func get_neighbor_num():
	return _neighbor_mine_num

func show_cell():
	_is_shown = true
	if is_flag():
		add_or_remove_flag()
	elif _is_mine:
		$Background.get_node("Mine").visible = true
		# $Label.text = "M"
		# $Background.color = Color(0, 0, 0)
	elif _neighbor_mine_num > 0:
		$Label.text = str(_neighbor_mine_num)
	else:
		$Background.color = Color(185 / 255.0, 185 / 255.0, 185 / 255.0)

func is_shown():
	return _is_shown

func add_or_remove_flag() -> bool:  # return if now has a flag
	if _is_flag:  # with flag
		_is_flag = false
		# $Label.text = ""
		# $Background.color = _init_color
		$Background.get_node("Flag").visible = false
		return false
	else:  # without flag
		_is_flag = true
		# $Label.text = "F"
		# $Background.color = Color(0.5, 0.5, 0)
		$Background.get_node("Flag").visible = true
		return true

func is_flag():
	return _is_flag
