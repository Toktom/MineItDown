package mineitdown

import rl "vendor:raylib"

GameState :: struct {
	target:                Vec2i,
	grid_cells:            [GRID_WIDTH][GRID_HEIGHT]Vec2i,
	interactables:		 [GRID_WIDTH][GRID_HEIGHT]Interactable,
	blocks:                [GRID_WIDTH][GRID_HEIGHT]Block,
	game_over:             bool,
	update:                proc(game_state: ^GameState),
}

game_state: GameState

init_game :: proc() {
	game_state = {} // Reset to defaults
	game_state.game_over = false
	game_state.update = proc(game_state: ^GameState) {
		if is_game_over() {
			game_state.game_over = true
		}
	}

	init_grid_cells()
	init_interactables()
	init_blocks()
	init_player()
	remove_block(1, 1)
	change_block(1, 1, BlockType.MossyStoneCracked)
	change_block(2, 2, BlockType.MossyStone)
	change_block(3, 3, BlockType.MossyStone)
}


is_game_over :: proc() -> bool {
	// Count inactive blocks (assuming game over happens when all blocks are mined)
	inactive_blocks := 0

	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if game_state.blocks[x][y].status == State.Inactive {
				inactive_blocks += 1
			}
		}
	}

	// Game is over when all blocks have been mined
	// (adjust this condition based on your actual game rules)
	return inactive_blocks == MAX_GRID_CELLS
}
