package mineitdown

import rl "vendor:raylib"


Interactable :: struct {
	pos:         Vec2i,
	status:      State,
	type:        InteractableType,
	// Cached values for drawing
	screen_pos:  rl.Vector2,
	source_rect: rl.Rectangle,
	dest_rect:   rl.Rectangle,
	draw:        proc(interactable: ^Interactable),
}

init_interactable :: proc(grid_pos: Vec2i) -> Interactable {
	interactable := Interactable {
		pos    = grid_pos,
		status = State.Inactive,
		type   = InteractableType.None,
	}
	interactable.screen_pos = convert_grid_to_screen(grid_pos)
	interactable.dest_rect = rl.Rectangle{interactable.screen_pos.x, interactable.screen_pos.y, CELL_SIZE, CELL_SIZE}

	interactable.draw = proc(interactable: ^Interactable) {
		texture_name: string
		switch interactable.type {
		case InteractableType.Door:
			texture_name = "stone_cracked"
		case InteractableType.Gem:
			texture_name = "gem"
		case InteractableType.King:
			texture_name = "king"
		case InteractableType.BombSquare:
			texture_name = "bomb_square"
		case InteractableType.BombHorizontal:
			texture_name = "bomb_h"
		case InteractableType.BombVertical:
			texture_name = "bomb_v"
		case InteractableType.BombCross:
			texture_name = "bomb"
		case InteractableType.None:
			return // Don't draw anything for None type, early return
		}

		// Only proceed if we have a valid texture name
		if len(texture_name) == 0 {
			return // Skip drawing if texture_name is empty
		}

		// Get texture data from atlas
		texture_data, exists := atlas.data.frames[texture_name]
		if !exists {
			return
		}

		// Create source rectangle from frame data
		source_rect := rl.Rectangle {
			f32(texture_data.frame.x),
			f32(texture_data.frame.y),
			f32(texture_data.frame.w),
			f32(texture_data.frame.h),
		}

		// Create destination rectangle, centering the trimmed texture
		dest_rect := interactable.dest_rect

		// For trimmed textures, adjust position to center it in the cell
		if texture_data.trimmed {
			// Calculate scaling factor (from original texture size to our cell size)
			scale_factor := CELL_SIZE / f32(texture_data.sourceSize.w)

			// Adjust destination rectangle to center the texture
			dest_rect.x += f32(texture_data.spriteSourceSize.x) * scale_factor
			dest_rect.y += f32(texture_data.spriteSourceSize.y) * scale_factor
			dest_rect.width = f32(texture_data.spriteSourceSize.w) * scale_factor
			dest_rect.height = f32(texture_data.spriteSourceSize.h) * scale_factor
		}

		rl.DrawTexturePro(atlas.texture, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
	}
	return interactable
}

get_interactable :: proc(x: int, y: int) -> ^Interactable {
	interactable := &game_state.current_level.interactables[x][y]
	return interactable
}

update_interactable_drawing_cache :: proc(interactable: ^Interactable) {
	interactable.screen_pos = convert_grid_to_screen(interactable.pos)
	interactable.dest_rect = rl.Rectangle{interactable.screen_pos.x, interactable.screen_pos.y, CELL_SIZE, CELL_SIZE}
}

init_interactables :: proc(grid_cells: ^Grid2i) -> Interactables2i {
	interactables := make(Interactables2i, GRID_WIDTH)
	for x in 0 ..< GRID_WIDTH {
		interactables[x] = make([dynamic]Interactable, GRID_HEIGHT)
		for y in 0 ..< GRID_HEIGHT {
			interactables[x][y] = init_interactable(grid_cells[x][y])
		}
	}
	return interactables
}

render_active_interactables :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			interactable := get_interactable(x, y)

			if interactable.status == State.Active && get_block(x, y).status == State.Inactive {
				interactable->draw()
			}
		}
	}
}

is_interactable_active :: proc(x: int, y: int) -> bool {
	interactable := game_state.current_level.interactables[x][y]
	return interactable.status == State.Active
}

set_interactable_type :: proc(x: int, y: int, interactable_type: InteractableType) {
	interactable := get_interactable(x, y)
	if interactable.status == State.Inactive {
		interactable.status = State.Active
		interactable.type = interactable_type
	} else {return}
	update_interactable_drawing_cache(interactable)
}

remove_interactable :: proc(x: int, y: int) {
	interactable := get_interactable(x, y)
	if interactable.status == State.Active {
		interactable.status = State.Inactive
		interactable.type = InteractableType.None
	}
}

activate_interactable :: proc(x: int, y: int) {
	interactable := get_interactable(x, y)
	if interactable.status != State.Active {
		return
	}

	switch interactable.type {
	case InteractableType.Door:
		load_next_level()
	case InteractableType.Gem, InteractableType.King:
		game_state.game_over = true
	case InteractableType.BombSquare:
		apply_bomb_effect(x, y, mine_surrounding_blocks)
	case InteractableType.BombHorizontal:
		apply_bomb_effect(x, y, mine_blocks_horizontally)
	case InteractableType.BombVertical:
		apply_bomb_effect(x, y, mine_blocks_vertically)
	case InteractableType.BombCross:
		apply_bomb_effect(x, y, proc(x, y: int) {
			mine_blocks_horizontally(x, y)
			mine_blocks_vertically(x, y)
		})
	case InteractableType.None:
		return
	}
}

// Helper to apply bomb effect and then remove the bomb
apply_bomb_effect :: proc(x: int, y: int, effect: proc(x: int, y: int)) {
	effect(x, y)
	remove_interactable(x, y)
}

// Mine blocks in a 3x3 area, excluding the center
mine_surrounding_blocks :: proc(x: int, y: int) {
	for row in -1 ..< 2 {
		for col in -1 ..< 2 {
			if row == 0 && col == 0 {
				continue // Skip the center block
				}
			// Calculate target coordinates
			target_x := x + row
			target_y := y + col
			// Check if target coordinates are within grid boundaries
			if target_x >= 0 && target_x < GRID_WIDTH && target_y >= 0 && target_y < GRID_HEIGHT {
				if get_block(target_x, target_y).status == State.Active {
					damage_block(target_x, target_y)
				}
			}
		}
	}
}

// Mine all blocks in the row
mine_blocks_vertically :: proc(x: int, y: int) {
	for col in 0 ..< GRID_WIDTH {
		if get_block(col, y).status == State.Active {
			damage_block(col, y)
		}
	}
}

// Mine all blocks in the column
mine_blocks_horizontally :: proc(x: int, y: int) {
	for row in 0 ..< GRID_HEIGHT {
		if get_block(x, row).status == State.Active {
			damage_block(x, row)
		}
	}
}
