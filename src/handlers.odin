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

	if target.x > current_player_position.x {
		move_direction = Movement_Vectors[.Right]
	} else if target.x < current_player_position.x {
		move_direction = Movement_Vectors[.Left]
	} else if target.y > current_player_position.y {
		move_direction = Movement_Vectors[.Down]
	} else if target.y < current_player_position.y {
		move_direction = Movement_Vectors[.Up]
	}
}

handle_select_key_input :: proc() {
	if rl.IsMouseButtonPressed(.LEFT) {
		// get mouse position and get the respective cell index       
		blocks[current_player_position.x][current_player_position.y].status = CellStatus.Inactive
		blocks[current_player_position.x][current_player_position.y].type = CellType.Empty
		}
	
}
