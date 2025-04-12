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
		status = State.Active,
		type   = InteractableType.None,
	}
	interactable.screen_pos = convert_grid_to_screen(grid_pos)
	interactable.dest_rect = rl.Rectangle{interactable.screen_pos.x, interactable.screen_pos.y, CELL_SIZE, CELL_SIZE}

	interactable.draw = proc(interactable: ^Interactable) {
		texture_name : string 
		switch interactable.type {
		case InteractableType.Door:
			texture_name = "door"
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
		case InteractableType.BombDiagonal:
			texture_name = "bomb_d"
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
		source_rect := rl.Rectangle{
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
		
		rl.DrawTexturePro(
			atlas.texture, 
			source_rect, 
			dest_rect, 
			{0, 0}, 
			0, 
			rl.WHITE
		)
	}
	return interactable
}

update_interactable_drawing_cache :: proc(interactable: ^Interactable) {
    interactable.screen_pos = convert_grid_to_screen(interactable.pos)
    interactable.dest_rect = rl.Rectangle{interactable.screen_pos.x, interactable.screen_pos.y, CELL_SIZE, CELL_SIZE}
}

init_interactables :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.interactables[x][y] = init_interactable(game_state.grid_cells[x][y])
		}
	}
}

render_active_interactables :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			interactable := &game_state.interactables[x][y]

			if interactable.status == State.Active && game_state.blocks[x][y].status == State.Inactive {
				interactable->draw()
			}
		}
	}
}

is_interactable_active :: proc(x: int, y: int) -> bool {
	interactable := game_state.interactables[x][y]
	return interactable.status == State.Active
}

add_interactable :: proc(x: int, y: int, interactable_type: InteractableType) {
	interactable := &game_state.interactables[x][y]
	if interactable.status == State.Active {
		interactable.type = interactable_type
	} else {
		interactable.status = State.Active
		interactable.type = interactable_type
	}
	update_interactable_drawing_cache(interactable)
}

remove_interactable :: proc(x: int, y: int) {
	interactable := &game_state.interactables[x][y]
	if interactable.status == State.Active {
		interactable.status = State.Inactive
		interactable.type = InteractableType.None
	}
}

interact_with_interactable :: proc(x: int, y: int) {
	interactable := &game_state.interactables[x][y]
	if interactable.status == State.Active {
		switch interactable.type {
		case InteractableType.Door:
			game_state.game_over = true
		case InteractableType.Gem:
			game_state.game_over = true
		case InteractableType.King:
			game_state.game_over = true
		case InteractableType.BombSquare:
			remove_interactable(x, y)
		case InteractableType.BombHorizontal:
			mine_all_blocks_in_x_direction(x, y)
			remove_interactable(x, y)
		case InteractableType.BombVertical:
			mine_all_blocks_in_y_direction(x, y)
			remove_interactable(x, y)
		case InteractableType.BombCross:
			// get all active blocks in x+ and x-, y+ and y- direction and "mine" them
			mine_all_blocks_in_x_direction(x, y)
			mine_all_blocks_in_y_direction(x, y)

			remove_interactable(x, y)
		case InteractableType.BombDiagonal:
			remove_interactable(x, y)
		case InteractableType.None:
			// Do nothing for None type
			return // Early return to avoid further processing

		}
	}
}


mine_all_blocks_in_y_direction :: proc(x: int, y: int) {
	// Remove blocks in the x direction (left and right)
	for i in 0 ..< GRID_WIDTH {
		if game_state.blocks[i][y].status == State.Active {
			remove_block(i, y)
		}
	}
}
mine_all_blocks_in_x_direction :: proc(x: int, y: int) {
	// Remove blocks in the y direction (up and down)
	for j in 0 ..< GRID_HEIGHT {
		if game_state.blocks[x][j].status == State.Active {
			remove_block(x, j)
		}
	}
}