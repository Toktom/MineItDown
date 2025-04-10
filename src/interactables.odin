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
	interactable.source_rect = rl.Rectangle{0, 0, f32(SPRITE_TEXTURE_SIZE), f32(SPRITE_TEXTURE_SIZE)}
	interactable.dest_rect = rl.Rectangle{interactable.screen_pos.x, interactable.screen_pos.y, CELL_SIZE, CELL_SIZE}
	interactable.draw = proc(interactable: ^Interactable) {
		// Use cached values instead of recalculating
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

			if interactable.status == State.Active {
				interactable->draw()
			}
		}
	}
}

is_interactable_active :: proc(x: int, y: int) -> bool {
	interactable := game_state.interactables[x][y]
	return interactable.status == State.Active
}
