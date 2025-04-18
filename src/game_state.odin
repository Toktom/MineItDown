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
		if game_state.current_level.level == 100 {
			game_state.game_over = true
		}
	}
	init_level_0()
	init_player()
}
