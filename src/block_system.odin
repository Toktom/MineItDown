package mineitdown

import rl "vendor:raylib"

// Init functions
init_grid_cells :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			cell := Cell{{x, y}}
			game_state.grid_cells[x][y] = cell
		}
	}
}
init_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			cell := game_state.grid_cells[x][y]

			block := Block{cell, BlockState.Active, BlockType.Stone}
			game_state.blocks[x][y] = block
		}
	}
}

draw_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			block := game_state.blocks[x][y]
			block_pos := convert_grid_to_screen(block.pos)

			if block.status == BlockState.Active {
				// Draw the cell based on its type
				source_rect := rl.Rectangle{0, 0, f32(SPRITE_TEXTURE_SIZE), f32(SPRITE_TEXTURE_SIZE)}
				dest_rect := rl.Rectangle{block_pos.x, block_pos.y, CELL_SIZE, CELL_SIZE}

				switch block.type {
				case BlockType.Stone:
					rl.DrawTexturePro(stone_sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
				case BlockType.MossyStone:
					rl.DrawTexturePro(mossy_stone_sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
				case BlockType.MossyStoneCracked:
					rl.DrawTexturePro(mossy_stone_cracked_sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
				case BlockType.Empty:
				// Do nothing for empty cells
				}
			}
		}
	}
}

draw_background_board :: proc() {
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

remove_block :: proc(x: int, y: int) {
	if game_state.blocks[x][y].status == BlockState.Active {
		game_state.blocks[x][y].status = BlockState.Inactive
		game_state.blocks[x][y].type = BlockType.Empty
	}

}
