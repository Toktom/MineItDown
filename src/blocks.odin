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

	update_block_appearance(&block)
	return block
}

update_block_appearance :: proc(block: ^Block) {
	// Update visual properties based on block type
	texture_name := get_block_texture_name(block.type)
	if texture_name != "" {
		block.source_rect = load_texture_from_atlas_as_rectangle(texture_name)
	}
	
	block.screen_pos = convert_grid_to_screen(block.pos)
	block.dest_rect = rl.Rectangle{block.screen_pos.x, block.screen_pos.y, CELL_SIZE, CELL_SIZE}
	
	if block.draw == nil {
		block.draw = create_block_draw_proc()
	}
}

get_block_texture_name :: proc(block_type: BlockType) -> string {
	switch block_type {
	case BlockType.Stone:
		return "stone"
	case BlockType.MossyStone:
		return "mossy_stone"
	case BlockType.MossyStoneCracked:
		return "mossy_stone_cracked"
	case BlockType.Empty:
		return ""
	}
	return ""
}

create_block_draw_proc :: proc() -> proc(block: ^Block) {
	return proc(block: ^Block) {
		texture_name := get_block_texture_name(block.type)
		if texture_name == "" {
			return // Don't draw anything for empty cells
		}
		
		block.source_rect = load_texture_from_atlas_as_rectangle(texture_name)
		rl.DrawTexturePro(atlas.texture, block.source_rect, block.dest_rect, {0, 0}, 0, rl.WHITE)
	}
}

update_block_drawing_cache :: proc(block: ^Block) {
	block.screen_pos = convert_grid_to_screen(block.pos)
	block.dest_rect = rl.Rectangle{block.screen_pos.x, block.screen_pos.y, CELL_SIZE, CELL_SIZE}
}

init_blocks :: proc(grid_cells: ^Grid2i) -> Blocks2i {
	blocks := make(Blocks2i, GRID_WIDTH)
	for x in 0 ..< GRID_WIDTH {
		blocks[x] = make([dynamic]Block, GRID_HEIGHT)
		for y in 0 ..< GRID_HEIGHT {
			blocks[x][y] = init_block(grid_cells[x][y])
		}
	}
	return blocks
}

render_active_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			block := get_block(x, y)
			if block.status == State.Active {
				block->draw()
			}
		}
	}
}

// Add helper function to get block reference - reduces repetition
get_block :: proc(x, y: int) -> ^Block {
	return &game_state.current_level.blocks[x][y]
}

deactivate_block :: proc(x: int, y: int) {
	block := get_block(x, y)
	if block.status == State.Active {
		block.status = State.Inactive
		block.type = BlockType.Empty
		block.health = 0
	}
}

damage_block :: proc(x: int, y: int) {
	block := get_block(x, y)
	block.health = max(0, block.health - player.damage)
	
	emit_block_damage_particles({x, y})
	
	if block.type == BlockType.MossyStone && block.health == 1 {
		set_block_type(x, y, BlockType.MossyStoneCracked)
	} else if block.health <= 0 {
		deactivate_block(x, y)
	}
}

set_block_type :: proc(x: int, y: int, new_block_type: BlockType) {
	block := get_block(x, y)
	if block.status == State.Active {
		block.type = new_block_type
		apply_block_type_properties(block)
		update_block_appearance(block)
	}
}

apply_block_type_properties :: proc(block: ^Block) {
	switch block.type {
	case BlockType.Stone:
		block.health = 1
	case BlockType.MossyStone:
		block.health = 2
	case BlockType.MossyStoneCracked:
		block.health = 1
	case BlockType.Empty:
		block.health = 0
	}
}

is_block_active :: proc(x: int, y: int) -> bool {
	return get_block(x, y).status == State.Active
}
