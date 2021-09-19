extends GridContainer

var row_num: int = 16
var col_num: int = 16
var mine_num: int = 40

export (PackedScene) var Cell

var cell_matrix := []
var is_first_click := true  # generate mines after first click
var is_game_over := false

const eight_neighbor = [[-1, -1], [-1, 0], [-1, 1],
						[0, -1], [0, 1],
						[1, -1], [1, 0], [1, 1]]

func new_game(row, col, mine):
	is_first_click = true
	is_game_over = false
	create_cells(row, col)
	mine_num = mine

func create_cells(row, col):
	assert(typeof(row) == TYPE_INT and typeof(col) == TYPE_INT)
	assert(row > 0 and col > 0)
	assert(row <= 50 and col <= 50)
	
	columns = col  # for grid container
	
	for i in range(len(cell_matrix)):
		for j in range(len(cell_matrix[i])):
			cell_matrix[i][j].queue_free()
	
	cell_matrix.clear()
	
	for i in range(row):
		cell_matrix.append([])
		for j in range(col):
			var cell = Cell.instance()
			cell.set_row_col(i, j)
			add_child(cell)
			
			cell.connect("click_cell", self, "_on_Cell_click_cell")
			cell_matrix[-1].append(cell)

# Called when the node enters the scene tree for the first time.
func _ready():
	# randomize()  # disable it when developing
	new_game(row_num, col_num, mine_num)

func _on_Cell_click_cell(left_or_right, row, col):  # signal function
	if is_game_over:
		return
	if left_or_right:
		left_click_cell(row, col)
	else:
		right_click_cell(row, col)

func left_click_cell(row, col):  # left click event
	if is_first_click:  # when first click, there is no mine
		generate_mines(row, col)
		is_first_click = false
	
	var curr_cell = cell_matrix[row][col]
	
	if curr_cell.is_shown() and not curr_cell.is_mine():
		# calculate neighbor flag num
		var flag_num = 0
		for i in range(len(eight_neighbor)):
			var new_r = row + eight_neighbor[i][0]
			var new_c = col + eight_neighbor[i][1]
			if (new_r >= 0 and new_r < row_num and new_c >= 0 and new_c < col_num):
				if (cell_matrix[new_r][new_c].is_flag()):
					flag_num += 1
		if curr_cell.get_neighbor_num() == flag_num:
			open_eight_neighbor_cell(row, col, false)
	
	if curr_cell.is_flag():
		return
	open_cell(row, col)
	
	
func right_click_cell(row, col):  # right click event
	var curr_cell = cell_matrix[row][col]
	if curr_cell.is_shown():
		return
	var now_has_flag = curr_cell.add_or_remove_flag()

func open_cell(row, col):
	if cell_matrix[row][col].is_shown():
		return
	cell_matrix[row][col].show()
	if cell_matrix[row][col].is_mine():  # mine
		# print("Game Over")
		is_game_over = true
		return
	if not cell_matrix[row][col].is_mine() and cell_matrix[row][col].get_neighbor_num() == 0:
		open_eight_neighbor_cell(row, col)

func open_eight_neighbor_cell(row, col, ignore_flag: bool=true):
	for i in range(len(eight_neighbor)):
		var new_r = row + eight_neighbor[i][0]
		var new_c = col + eight_neighbor[i][1]
		if (new_r >= 0 and new_r < row_num and new_c >= 0 and new_c < col_num):
			if ignore_flag or not cell_matrix[new_r][new_c].is_flag():
				open_cell(new_r, new_c)

func generate_mines(exclude_row: int, exclude_col: int):
	var arrays = []
	for i in range(row_num):
		for j in range(col_num):
			if exclude_row == i and exclude_col == j:
				break
			arrays.append([i, j])
	arrays.shuffle()
	for idx in range(min(mine_num, len(arrays))):
		var r = arrays[idx][0]
		var c = arrays[idx][1]
		cell_matrix[r][c].set_mine(true)
		
		# calculate neighbor
		for i in range(len(eight_neighbor)):
			var new_r = r + eight_neighbor[i][0]
			var new_c = c + eight_neighbor[i][1]
			if (new_r >= 0 and new_r < row_num and new_c >= 0 and new_c < col_num):
				cell_matrix[new_r][new_c].add_neighbor_num()

func _on_Restart_button_up():
	new_game(row_num, col_num, mine_num)
