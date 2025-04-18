package mineitdown

import "core:fmt"
import rl "vendor:raylib"

draw_ui :: proc() {
	
	rl.DrawText(
		fmt.ctprintf("Level: %v", get_current_level().level),
		360,
		5,
		70,
		rl.GREEN,
	)

	// Add other UI elements as needed
	if game_state.game_over {
		rl.DrawText(
			"You finished the game!\n Press R to restart.",
			i32(BOARD_OFFSET_X + 50),
			i32(BOARD_OFFSET_Y + BOARD_SIZE_HEIGHT / 2),
			30,
			rl.RED,
		)
	}
}
