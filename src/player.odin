package mineitdown

import rl "vendor:raylib"

draw_player :: proc() {
	player_current_pos := convert_grid_to_screen(game_state.player_pos)
	player_source_rect := rl.Rectangle{0, 0, f32(SPRITE_TEXTURE_SIZE), f32(SPRITE_TEXTURE_SIZE)}
	player_dest_rect := rl.Rectangle{player_current_pos.x, player_current_pos.y, CELL_SIZE, CELL_SIZE}

	rl.DrawTexturePro(player_sprite, player_source_rect, player_dest_rect, {0, 0}, 0, rl.WHITE)
}

// Moving existing player-related functions from mineitdown.odin
move_player :: proc() {
	// Calculate new position
	new_pos := Vec2i {
		game_state.player_pos.x + game_state.player_move_direction.x,
		game_state.player_pos.y + game_state.player_move_direction.y,
	}

	// Check bounds
	if new_pos.x >= 0 && new_pos.x < GRID_WIDTH && new_pos.y >= 0 && new_pos.y < GRID_HEIGHT {
		game_state.player_pos = new_pos
	}

	// Reset movement direction after moving
	game_state.player_move_direction = {0, 0}
}

// Additional player-related functions
init_player :: proc() {
	// Set initial player position
	game_state.player_pos = {GRID_WIDTH / 2, GRID_HEIGHT / 2}
	game_state.player_move_direction = {0, 0}

	// Center mouse on player
	screen_center := grid_to_screen_center(game_state.player_pos)
	zoom := DEFAULT_CAMERA_ZOOM
	rl.SetMousePosition(i32(screen_center.x * zoom), i32(screen_center.y * zoom))
}

player_actions :: proc() {
	handle_player_mouse_position()
	if rl.IsMouseButtonPressed(.LEFT) {
		remove_block(game_state.player_pos.x, game_state.player_pos.y)
	}

}
