package mineitdown

import rl "vendor:raylib"

Player :: struct {
    pos:            Vec2i,
    move_direction: Vec2i,
    damage:         int,
    target:         Vec2i,
}

player: Player

init_player :: proc() {
    // Reset player data
    player = {}
    player.damage = 1
    
    // Set initial player position
    player.pos = {GRID_WIDTH / 2, GRID_HEIGHT / 2}
    player.move_direction = {0, 0}

    // Center mouse on player
    screen_center := grid_to_screen_center(player.pos)
    zoom := DEFAULT_CAMERA_ZOOM
    rl.SetMousePosition(i32(screen_center.x * zoom), i32(screen_center.y * zoom))
}

draw_player :: proc() {
	player_current_pos := convert_grid_to_screen(player.pos)
	player_source_rect := rl.Rectangle{0, 0, f32(SPRITE_TEXTURE_SIZE), f32(SPRITE_TEXTURE_SIZE)}
	player_dest_rect := rl.Rectangle{player_current_pos.x, player_current_pos.y, CELL_SIZE, CELL_SIZE}

	rl.DrawTexturePro(player_sprite, player_source_rect, player_dest_rect, {0, 0}, 0, rl.WHITE)
}

// Moving existing player-related functions from mineitdown.odin
move_player :: proc() {
	// Calculate new position
	new_pos := Vec2i {
		player.pos.x + player.move_direction.x,
		player.pos.y + player.move_direction.y,
	}

	// Check bounds
	if new_pos.x >= 0 && new_pos.x < GRID_WIDTH && new_pos.y >= 0 && new_pos.y < GRID_HEIGHT {
		player.pos = new_pos
	}

	// Reset movement direction after moving
	player.move_direction = {0, 0}
}

player_actions :: proc() {
	handle_player_mouse_position()
	if rl.IsMouseButtonPressed(.LEFT) {
		mine_block(player.pos.x, player.pos.y)
	}

}
