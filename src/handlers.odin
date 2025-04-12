package mineitdown

import "core:fmt"
import rl "vendor:raylib"

handle_game_over_key_input :: proc() {
	if rl.IsKeyPressed(.R) {
		init_game()
	}
}

handle_left_click :: proc(pos: Vec2i) {
	if rl.IsMouseButtonPressed(.LEFT) {
		if game_state.blocks[pos.x][pos.y].status == State.Active {
			mine_block(pos.x, pos.y)
		} else {
			if game_state.interactables[pos.x][pos.y].status == State.Active {
				interact_with_interactable(pos.x, pos.y)
			}
		}
	}


}

handle_player_mouse_position :: proc() {
	// Calculate direction toward mouse (prioritizing horizontal movement)
	game_state.target = get_grid_coordinates_from_mouse()

	if game_state.target.x > player.pos.x {
		player.move_direction = MOVEMENT_VECTORS[.Right]
	} else if game_state.target.x < player.pos.x {
		player.move_direction = MOVEMENT_VECTORS[.Left]
	} else if game_state.target.y > player.pos.y {
		player.move_direction = MOVEMENT_VECTORS[.Down]
	} else if game_state.target.y < player.pos.y {
		player.move_direction = MOVEMENT_VECTORS[.Up]
	}
}
