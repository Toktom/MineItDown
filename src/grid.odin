package mineitdown

import rl "vendor:raylib"


init_grid_cells :: proc() -> Grid2i{
	grid_cells : Grid2i
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			grid_cells[x][y] = {x, y}
		}
	}
	return grid_cells
}

render_background_board :: proc() {
	// Draw big rectangle background with offset
	background_rect := rl.Rectangle{BOARD_OFFSET_X, BOARD_OFFSET_Y, BOARD_SIZE_WIDTH, BOARD_SIZE_HEIGHT}
	rl.DrawRectangleRec(background_rect, BOARD_COLORS_MAP[BoardColorType.Background])

	// Draw the board pattern (checkerboard) with offset
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if (x + y) % 2 == 0 {
				rect := rl.Rectangle {
					BOARD_OFFSET_X + (f32(x) * CELL_SIZE),
					BOARD_OFFSET_Y + (f32(y) * CELL_SIZE),
					CELL_SIZE,
					CELL_SIZE,
				}
				rl.DrawRectangleRec(rect, BOARD_COLORS_MAP[BoardColorType.Pattern])
			}
		}
	}

	// Draw grid lines with offset
	for x in 0 ..< GRID_WIDTH + 1 {
		start_pos := rl.Vector2{BOARD_OFFSET_X + (f32(x) * CELL_SIZE), BOARD_OFFSET_Y}
		end_pos := rl.Vector2{BOARD_OFFSET_X + (f32(x) * CELL_SIZE), BOARD_OFFSET_Y + BOARD_SIZE_HEIGHT}
		rl.DrawLineEx(start_pos, end_pos, GRID_LINE_WIDTH, BOARD_COLORS_MAP[BoardColorType.Line])
	}

	for y in 0 ..< GRID_HEIGHT + 1 {
		start_pos := rl.Vector2{BOARD_OFFSET_X, BOARD_OFFSET_Y + (f32(y) * CELL_SIZE)}
		end_pos := rl.Vector2{BOARD_OFFSET_X + BOARD_SIZE_WIDTH, BOARD_OFFSET_Y + (f32(y) * CELL_SIZE)}
		rl.DrawLineEx(start_pos, end_pos, GRID_LINE_WIDTH, BOARD_COLORS_MAP[BoardColorType.Line])
	}
}
