package mineitdown

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
// Variables
player_possible_position: [MAX_GRID_CELLS]Vec2i
current_player_position: Vec2i
target: Vec2i
move_direction: Vec2i
game_over: bool
grid_cells: [GRID_WIDTH][GRID_HEIGHT]Cell
blocks: [GRID_WIDTH][GRID_HEIGHT]Block
current_grid_cells := MAX_GRID_CELLS

// Icon
icon_path: cstring = "assets/stone_cracked.png"

// Init functions
init_grid_cells :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			cell := Cell{{x, y}}
			grid_cells[x][y] = cell
		}
	}
}
init_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			cell := grid_cells[x][y]

			block := Block{cell, CellStatus.Active, CellType.Stone}
			blocks[x][y] = block
		}
	}
}

init_game :: proc() {
	game_over = false
	init_grid_cells()
	init_blocks()
	empty_a_block(1, 1)

	current_player_position = {GRID_WIDTH / 2, GRID_HEIGHT / 2} // Start in the center
	move_direction = {0, 0}

	// Calculate center of the middle cell in screen coordinates
	screen_center := grid_to_screen_center(current_player_position)
	zoom := DEFAULT_CAMERA_ZOOM
	rl.SetMousePosition(i32(screen_center.x * zoom), i32(screen_center.y * zoom))

	// Reset other game state here
}

draw_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			block := blocks[x][y]
			block_pos := grid_to_screen(block.pos)

			if block.status == CellStatus.Active {
				// Draw the cell based on its type
				source_rect := rl.Rectangle{0, 0, f32(TEXTURE_SIZE), f32(TEXTURE_SIZE)}
				dest_rect := rl.Rectangle{block_pos.x, block_pos.y, CELL_SIZE, CELL_SIZE}

				switch block.type {
				case CellType.Stone:
					rl.DrawTexturePro(stone_sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
				case CellType.MossyStone:
					rl.DrawTexturePro(mossy_stone_sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
				case CellType.MossyStoneCracked:
					rl.DrawTexturePro(mossy_stone_cracked_sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
				case CellType.Empty:
				// Do nothing for empty cells
				}
			}
		}
	}
}

draw_background_board :: proc() {
	// Draw big rectangle background with offset
	background_rect := rl.Rectangle{BOARD_OFFSET_X, BOARD_OFFSET_Y, BOARD_WIDTH, BOARD_HEIGHT}
	rl.DrawRectangleRec(background_rect, BOARD_COLORS[BoardColors.Background])

	// Draw the board pattern (checkerboard) with offset
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if (x + y) % 2 == 0 {
				rect := rl.Rectangle {
					BOARD_OFFSET_X + (f32(x) * CELL_SIZE),
					BOARD_OFFSET_Y + (f32(y) * CELL_SIZE),
					CELL_SIZE,
					CELL_SIZE,
				}
				rl.DrawRectangleRec(rect, BOARD_COLORS[BoardColors.Pattern])
			}
		}
	}

	// Draw grid lines with offset
	for x in 0 ..< GRID_WIDTH + 1 {
		start_pos := rl.Vector2{BOARD_OFFSET_X + (f32(x) * CELL_SIZE), BOARD_OFFSET_Y}
		end_pos := rl.Vector2{BOARD_OFFSET_X + (f32(x) * CELL_SIZE), BOARD_OFFSET_Y + BOARD_HEIGHT}
		rl.DrawLineEx(start_pos, end_pos, GRID_LINE_WIDTH, BOARD_COLORS[BoardColors.Line])
	}

	for y in 0 ..< GRID_HEIGHT + 1 {
		start_pos := rl.Vector2{BOARD_OFFSET_X, BOARD_OFFSET_Y + (f32(y) * CELL_SIZE)}
		end_pos := rl.Vector2{BOARD_OFFSET_X + BOARD_WIDTH, BOARD_OFFSET_Y + (f32(y) * CELL_SIZE)}
		rl.DrawLineEx(start_pos, end_pos, GRID_LINE_WIDTH, BOARD_COLORS[BoardColors.Line])
	}
}
empty_a_block ::proc(x:int, y:int) {
	if blocks[x][y].status == CellStatus.Active {
		blocks[x][y].status = CellStatus.Inactive
		blocks[x][y].type = CellType.Empty
	}
	
}
move_player :: proc() {
	// Calculate new position
	new_pos := Vec2i{current_player_position.x + move_direction.x, current_player_position.y + move_direction.y}

	// Check bounds
	if new_pos.x >= 0 && new_pos.x < GRID_WIDTH && new_pos.y >= 0 && new_pos.y < GRID_HEIGHT {
		current_player_position = new_pos
	}

	// Reset movement direction after moving
	move_direction = {0, 0}
}

check_game_over :: proc() -> bool {
	// Count inactive blocks (assuming game over happens when all blocks are mined)
	inactive_blocks := 0

	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if blocks[x][y].status == CellStatus.Inactive {
				inactive_blocks += 1
			}
		}
	}

	// Game is over when all blocks have been mined
	// (adjust this condition based on your actual game rules)
	return inactive_blocks == MAX_GRID_CELLS
}

game_loop :: proc() {
	for !rl.WindowShouldClose() {
		handle_player_mouse_position()
		handle_player_action()

		game_over = check_game_over()

		if game_over {
			handle_game_over_key_input()
		}
		move_player()


		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		//Camera
		camera := rl.Camera2D {
			target   = {BOARD_OFFSET_X + BOARD_WIDTH / 2, BOARD_OFFSET_Y + BOARD_HEIGHT / 2},
			offset   = {WINDOW_SIZE / 2, WINDOW_SIZE / 2},
			rotation = 0.0,
			zoom     = DEFAULT_CAMERA_ZOOM,
		}
		rl.BeginMode2D(camera)
		


		// Draw grid cell
		draw_background_board()
		draw_blocks()

		// Player
		player_pos := grid_to_screen(current_player_position)
		player_source_rect := rl.Rectangle {
			0,
			0,
			f32(TEXTURE_SIZE),
			f32(TEXTURE_SIZE),
		}
		player_dest_rect := rl.Rectangle{player_pos.x, player_pos.y, CELL_SIZE, CELL_SIZE}
		rl.DrawTexturePro(player_sprite, player_source_rect, player_dest_rect, {0, 0}, 0, rl.WHITE)

		rl.DrawText(
			fmt.ctprintf("Position: [%d][%d]", current_player_position.x, current_player_position.y),
			5,
			5,
			20,
			rl.BLUE,
		)
		rl.DrawText(
			fmt.ctprintf("Status: %v", blocks[current_player_position.x][current_player_position.y].status),
			5,
			25,
			20,
			rl.BLUE,
		)

		rl.EndMode2D()
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
}

set_window_icon :: proc() {
	if rl.FileExists(icon_path) {
		rl.SetWindowIcon(rl.LoadImage(icon_path))
	} else {
		rl.SetWindowIcon(rl.GenImageColor(16, 16, rl.RED))
	}
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Mine It Down!")
	rl.HideCursor()
	set_window_icon()
	//rl.InitAudioDevice()
	defer {
		unload_sprites()
		rl.ShowCursor()
		rl.CloseWindow()
	}
	//defer rl.CloseAudioDevice()
	init_game()
	load_sprites()
	game_loop()

}
