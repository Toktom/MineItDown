package mineitdown

import rl "vendor:raylib"


Block :: struct {
	pos:         Vec2i,
	status:      State,
	type:        BlockType,
	health:      int,
	// Cached values for drawing
	screen_pos:  rl.Vector2,
	source_rect: rl.Rectangle,
	dest_rect:   rl.Rectangle,
	draw:        proc(block: ^Block),
}

init_block :: proc(grid_pos: Vec2i) -> Block {
	block := Block {
		pos    = grid_pos,
		status = State.Active,
		type   = BlockType.Stone,
		health = 1,
	}

	// Use corresponding texture for block type
	block.source_rect = load_texture_from_atlas_as_rectangle("stone")
	block.screen_pos = convert_grid_to_screen(grid_pos)
	block.dest_rect = rl.Rectangle{block.screen_pos.x, block.screen_pos.y, CELL_SIZE, CELL_SIZE}
	block.draw = proc(block: ^Block) {
		// Use cached values instead of recalculating
		texture_name: string
		switch block.type {
		case BlockType.Stone:
			texture_name = "stone"
		case BlockType.MossyStone:
			texture_name = "mossy_stone"
		case BlockType.MossyStoneCracked:
			texture_name = "mossy_stone_cracked"
		case BlockType.Empty:
			return // Don't draw anything for empty cells
		}
		block.source_rect = load_texture_from_atlas_as_rectangle(texture_name)
		rl.DrawTexturePro(atlas.texture, block.source_rect, block.dest_rect, {0, 0}, 0, rl.WHITE)
	}
	return block
}

update_block_drawing_cache :: proc(block: ^Block) {
	block.screen_pos = convert_grid_to_screen(block.pos)
	block.dest_rect = rl.Rectangle{block.screen_pos.x, block.screen_pos.y, CELL_SIZE, CELL_SIZE}
}

init_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.blocks[x][y] = init_block(game_state.grid_cells[x][y])
		}
	}
}

render_active_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			block := &game_state.blocks[x][y]

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
	
	if block.type == BlockType.MossyStone && block.health == 1 {
		change_block(x, y, BlockType.MossyStoneCracked)
	} else if block.health <= 0 {
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
