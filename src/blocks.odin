package mineitdown

import rl "vendor:raylib"


Block :: struct {
	pos:    Vec2i,
	status: State,
	type:   BlockType,
	health: int,
	draw:   proc(block: ^Block),
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

init_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.blocks[x][y] = init_block(game_state.grid_cells[x][y])
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
