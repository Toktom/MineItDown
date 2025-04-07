package mineitdown

import "core:fmt"
import rl "vendor:raylib"

draw_ui :: proc() {
	// Draw debug information
	rl.DrawText(
		fmt.ctprintf("Position: [%d][%d]", game_state.player_pos.x, game_state.player_pos.y),
		5,
		5,
		20,
		rl.BLUE,
	)

	rl.DrawText(
		fmt.ctprintf("Status: %v", game_state.blocks[game_state.player_pos.x][game_state.player_pos.y].status),
		5,
		25,
		20,
		rl.BLUE,
	)

	// Add other UI elements as needed
	if game_state.game_over {
		rl.DrawText(
			"GAME OVER! Press R to restart.",
			i32(BOARD_OFFSET_X + 50),
			i32(BOARD_OFFSET_Y + BOARD_SIZE_HEIGHT / 2),
			30,
			rl.RED,
		)
	}
}
