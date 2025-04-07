package mineitdown

import "core:fmt"
import rl "vendor:raylib"

handle_game_over_key_input :: proc() {
	if rl.IsKeyPressed(.R) {
		init_game()
	}
}

handle_player_mouse_position :: proc() {
	// Calculate direction toward mouse (prioritizing horizontal movement)
	game_state.target = get_grid_coordinates_from_mouse()

	if game_state.target.x > game_state.player_pos.x {
		game_state.player_move_direction = MOVEMENT_VECTORS[.Right]
	} else if game_state.target.x < game_state.player_pos.x {
		game_state.player_move_direction = MOVEMENT_VECTORS[.Left]
	} else if game_state.target.y > game_state.player_pos.y {
		game_state.player_move_direction = MOVEMENT_VECTORS[.Down]
	} else if game_state.target.y < game_state.player_pos.y {
		game_state.player_move_direction = MOVEMENT_VECTORS[.Up]
	}
}
