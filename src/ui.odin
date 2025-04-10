package mineitdown

import "core:fmt"
import rl "vendor:raylib"

draw_ui :: proc() {
	// Draw debug information
	rl.DrawText(
		fmt.ctprintf("Position: [%d][%d]", player.pos.x, player.pos.y),
		5,
		5,
		20,
		rl.GREEN,
	)

	rl.DrawText(
		fmt.ctprintf("Status: %v", game_state.blocks[player.pos.x][player.pos.y].status),
		5,
		25,
		20,
		rl.BLUE,
	)

	rl.DrawText(
		fmt.ctprintf("Health: %v", game_state.blocks[player.pos.x][player.pos.y].health),
		5,
		45,
		20,
		rl.BLUE,
	)

		rl.DrawText(
		fmt.ctprintf("Status: %v", game_state.interactables[player.pos.x][player.pos.y].status),
		190,
		25,
		20,
		rl.ORANGE,
	)

	rl.DrawText(
		fmt.ctprintf("Type: %v", game_state.interactables[player.pos.x][player.pos.y].type),
		190,
		45,
		20,
		rl.ORANGE,
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
