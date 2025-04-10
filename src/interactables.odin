package mineitdown

import rl "vendor:raylib"


Interactable :: struct {
	pos:    Vec2i,
	status: State,
	type:   InteractableType,
	draw:   proc(block: ^Interactable),
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

init_interactables :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			game_state.interactables[x][y] = Interactable {
				game_state.grid_cells[x][y],
				State.Active,
				InteractableType.None,
				nil,
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

is_interactable_active :: proc(x: int, y: int) -> bool {
	interactable := game_state.interactables[x][y]
	return interactable.status == State.Active
}