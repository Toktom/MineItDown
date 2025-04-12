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
	init_level_0()
	init_player()
}


is_game_over :: proc() -> bool {
	// Count inactive blocks (assuming game over happens when all blocks are mined)
	inactive_blocks := 0

	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if get_block(x, y).status == State.Inactive && get_current_level().level == 2 {
				inactive_blocks += 1
			}
		}
	}

	// Game is over when all blocks have been mined
	// (adjust this condition based on your actual game rules)
	return inactive_blocks == MAX_GRID_CELLS
}
