package mineitdown

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

set_window_icon :: proc() {
	if rl.FileExists(icon_path) {
		rl.SetWindowIcon(rl.LoadImage(icon_path))
	} else {
		rl.SetWindowIcon(rl.GenImageColor(16, 16, rl.RED))
	}
}

cleanup_game :: proc() {
	unload_sprites()
	rl.ShowCursor()
	rl.CloseWindow()
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.WHITE)

	camera := rl.Camera2D {
		target   = {BOARD_OFFSET_X + BOARD_SIZE_WIDTH / 2, BOARD_OFFSET_Y + BOARD_SIZE_HEIGHT / 2},
		offset   = {WINDOW_SIZE_PX / 2, WINDOW_SIZE_PX / 2},
		rotation = 0.0,
		zoom     = DEFAULT_CAMERA_ZOOM,
	}
	rl.BeginMode2D(camera)

	draw_background_board()
	draw_blocks()
	player->draw()
	
	//draw_player()
	draw_ui()

	rl.EndMode2D()
	rl.EndDrawing()
}


update :: proc() {
	game_state->update()
	player->update()

	if game_state.game_over {
		handle_game_over_key_input()
	}

	move_player()
}


setup_game :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE_PX, WINDOW_SIZE_PX, "Mine It Down!")
	rl.HideCursor()
	set_window_icon()

	init_game()
	load_sprites()
}

game_loop :: proc() {
	for !rl.WindowShouldClose() {
		update()
		render()
		free_all(context.temp_allocator)
	}
}

main :: proc() {
	setup_game()
	game_loop()
	cleanup_game()
}
