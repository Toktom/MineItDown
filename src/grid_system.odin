package mineitdown

import rl "vendor:raylib"



Block :: struct {
	pos:		Vec2i,
	status:     State,
	type:       BlockType,
	health:     int,
	draw: proc(block: ^Block),
}

Interactable :: struct {
	pos:		Vec2i,
	status:     State,
	type:       InteractableType,
	draw: proc(block: ^Interactable),
}



// Init functions
init_grid_cells :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.grid_cells[x][y] = {x, y}
		}
	}
}

init_block :: proc(grid_pos: Vec2i) -> Block {
	block := Block{grid_pos, State.Active, BlockType.Stone, 1, nil}
	block.draw = proc(block: ^Block) {
		block_pos := convert_grid_to_screen(block.pos)
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
	return block
}

init_interactable :: proc(grid_pos: Vec2i) -> Interactable {
	interactable := Interactable{grid_pos, State.Active, InteractableType.None, nil}
	interactable.draw = proc(interactable: ^Interactable) {
		interactable_pos := convert_grid_to_screen(interactable.pos)
		source_rect := rl.Rectangle{0, 0, f32(SPRITE_TEXTURE_SIZE), f32(SPRITE_TEXTURE_SIZE)}
		dest_rect := rl.Rectangle{interactable_pos.x, interactable_pos.y, CELL_SIZE, CELL_SIZE}

		switch interactable.type {
				case InteractableType.None:
					// Do nothing for empty interactables
				case InteractableType.Door:
					// Draw door interactable
				case InteractableType.Gem:
					// Draw gem interactable
				case InteractableType.King:
					// Draw king interactable
				case InteractableType.BombSquare:
					// Draw bomb square interactable
				case InteractableType.BombHorizontal:
					// Draw bomb horizontal interactable
				case InteractableType.BombVertical:
					// Draw bomb vertical interactable
				case InteractableType.BombCross:
					// Draw bomb cross interactable
				case InteractableType.BombDiagonal:
					// Draw bomb diagonal interactable
				}
	}
	return interactable
}

init_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.blocks[x][y] = init_block(game_state.grid_cells[x][y])
		}
	}
}

init_interactables :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.interactables[x][y] = Interactable{game_state.grid_cells[x][y], State.Active, InteractableType.None, nil}
		}
	}
}

draw_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			block := game_state.blocks[x][y]
			block_pos := convert_grid_to_screen(block.pos)

			if block.status == State.Active {
				block->draw()
			}
		}
	}
}

draw_interactables :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			interactable := game_state.interactables[x][y]
			interactable_pos := convert_grid_to_screen(interactable.pos)

			if interactable.status == State.Active {
				interactable->draw()				
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
	block := &game_state.blocks[x][y]
	if block.status == State.Active {
		block.status = State.Inactive
		block.type = BlockType.Empty
		block.health = 0
	}

}

mine_block :: proc(x: int, y: int) {
	block := &game_state.blocks[x][y]
	block.health = max(0, block.health - player.damage)

	if block.health <= 0 {
		remove_block(x, y)
	}
}

change_block :: proc(x: int, y: int, new_block_type: BlockType) {
	block := &game_state.blocks[x][y]
	if block.status == State.Active {
		switch new_block_type {
		case BlockType.Stone:
			block.type = BlockType.Stone
			block.health = 1
		case BlockType.MossyStone:
			block.type = BlockType.MossyStone
			block.health = 2
		case BlockType.MossyStoneCracked:
			block.type = BlockType.MossyStoneCracked
			block.health = 1
		case BlockType.Empty:
			block.type = BlockType.Empty
			block.health = 0
		}
	}
}

is_block_active :: proc(x: int, y: int) -> bool {
	block := game_state.blocks[x][y]
	return block.status == State.Active
}

is_interactable_active :: proc(x: int, y: int) -> bool {
	interactable := game_state.interactables[x][y]
	return interactable.status == State.Active
}

