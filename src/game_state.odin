package mineitdown

import rl "vendor:raylib"

GameState :: struct {
	target:        Vec2i,
	game_over:     bool,
	current_level: Level,
	update:        proc(game_state: ^GameState),
}

game_state: GameState

init_game :: proc(level: int) {
	game_state = {} // Reset to defaults
	game_state.game_over = false
	game_state.update = proc(game_state: ^GameState) {
		if is_game_over() {
			game_state.game_over = true
		}
	}

	init_level(level)
	init_player()
	deactivate_block(1, 1)
	set_block_type(1, 1, BlockType.MossyStoneCracked)
	set_block_type(2, 2, BlockType.MossyStone)
	set_block_type(3, 3, BlockType.MossyStone)
	set_interactable_type(1, 1, InteractableType.BombCross)
	set_interactable_type(2, 2, InteractableType.BombVertical)
	set_interactable_type(0, 1, InteractableType.BombHorizontal)
	set_interactable_type(3, 3, InteractableType.BombSquare)
}


is_game_over :: proc() -> bool {
	// Count inactive blocks (assuming game over happens when all blocks are mined)
	inactive_blocks := 0

	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if get_block(x, y).status == State.Inactive {
				inactive_blocks += 1
			}
		}
	}

	// Game is over when all blocks have been mined
	// (adjust this condition based on your actual game rules)
	return inactive_blocks == MAX_GRID_CELLS
}
