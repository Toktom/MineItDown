package mineitdown

import "core:fmt"
import "core:math"
import "core:time"
import rl "vendor:raylib"

set_window_icon :: proc() {
	if rl.FileExists(icon_path) {
		rl.SetWindowIcon(rl.LoadImage(icon_path))
	} else {
		rl.SetWindowIcon(rl.GenImageColor(16, 16, rl.RED))
	}
}

cleanup_game :: proc() {
	cleanup_particles()
	unload_atlas()
	rl.ShowCursor()
	rl.CloseWindow()
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color{38, 60, 57, 255})

	camera := rl.Camera2D {
		target   = {BOARD_OFFSET_X + BOARD_SIZE_WIDTH / 2, BOARD_OFFSET_Y + BOARD_SIZE_HEIGHT / 2},
		offset   = {WINDOW_SIZE_PX / 2, WINDOW_SIZE_PX / 2},
		rotation = 0.0,
		zoom     = DEFAULT_CAMERA_ZOOM,
	}
	rl.BeginMode2D(camera)

	render_background_board()
	render_active_blocks()
	render_active_interactables()
	draw_particles()
	player->draw()

	draw_ui()

	rl.EndMode2D()
	rl.EndDrawing()
}

update :: proc() {
	current_time := time.now()
	delta_time := f32(time.duration_seconds(time.diff(last_frame_time, current_time)))
	last_frame_time = current_time
	
	game_state->update()
	player->update()
	update_particles(delta_time)

	if game_state.game_over {
		handle_game_over_key_input()
	}

	move_player()
}

setup_game :: proc() {
	//rl.SetTraceLogLevel(rl.TraceLogLevel.NONE)
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE_PX, WINDOW_SIZE_PX, "Mine It Down!")
	rl.HideCursor()
	set_window_icon()
	init_atlas()
	init_particles()
	init_game(0)
}

// Add a variable to track frame time
last_frame_time: time.Time

game_loop :: proc() {
	last_frame_time = time.now()
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
