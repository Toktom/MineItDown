package mineitdown

import "core:fmt"
import rl "vendor:raylib"

handle_game_over_key_input :: proc() {
	if rl.IsKeyPressed(.ENTER) {
		init_game()
	}
}

handle_player_mouse_position :: proc() {
	// Calculate direction toward mouse (prioritizing horizontal movement)
	target = get_grid_coordinates_from_mouse()

	if target.x > player_pos.x {
		player_move_direction = MOVEMENT_VECTORS[.Right]
	} else if target.x < player_pos.x {
		player_move_direction = MOVEMENT_VECTORS[.Left]
	} else if target.y > player_pos.y {
		player_move_direction = MOVEMENT_VECTORS[.Down]
	} else if target.y < player_pos.y {
		player_move_direction = MOVEMENT_VECTORS[.Up]
	}
}

handle_player_action :: proc() {
	if rl.IsMouseButtonPressed(.LEFT) {
		remove_block(player_pos.x, player_pos.y)
		}
	
}
