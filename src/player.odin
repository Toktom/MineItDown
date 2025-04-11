package mineitdown

import rl "vendor:raylib"

Player :: struct {
	pos:            Vec2i,
	move_direction: Vec2i,
	damage:         int,
	target:         Vec2i,
	update:         proc(player: ^Player),
	draw:           proc(player: ^Player),
}

player: Player

init_player :: proc() {
	// Reset player data
	player = {}
	player.damage = 1
	player.update = proc(player: ^Player) {
		handle_player_mouse_position()
		handle_left_click(player.pos)
	}
	player.draw = proc(player: ^Player) {
		current_pos := convert_grid_to_screen(player.pos)
		source_rect := load_texture_from_atlas_as_rectangle("selection")
		dest_rect := rl.Rectangle{current_pos.x, current_pos.y, CELL_SIZE, CELL_SIZE}

		rl.DrawTexturePro(atlas.texture, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
	}
	// Set initial player position
	player.pos = {GRID_WIDTH / 2, GRID_HEIGHT / 2}
	player.move_direction = {0, 0}

	// Center mouse on player
	screen_center := grid_to_screen_center(player.pos)
	zoom := DEFAULT_CAMERA_ZOOM
	rl.SetMousePosition(i32(screen_center.x * zoom), i32(screen_center.y * zoom))
}

// Moving existing player-related functions from mineitdown.odin
move_player :: proc() {
	// Calculate new position
	new_pos := Vec2i{player.pos.x + player.move_direction.x, player.pos.y + player.move_direction.y}

	// Check bounds
	if new_pos.x >= 0 && new_pos.x < GRID_WIDTH && new_pos.y >= 0 && new_pos.y < GRID_HEIGHT {
		player.pos = new_pos
	}

	// Reset movement direction after moving
	player.move_direction = {0, 0}
}
