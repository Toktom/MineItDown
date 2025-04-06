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
grid_cells: [GRID_WIDTH][GRID_WIDTH]Cell
blocks: [GRID_WIDTH][GRID_WIDTH]Block
current_grid_cells := MAX_GRID_CELLS

// Init functions
init_grid_cells :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_WIDTH {
			cell := Cell{{x, y}}
			grid_cells[x][y] = cell
		}
	}
}
init_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_WIDTH {
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

	current_player_position = {GRID_WIDTH / 2, GRID_WIDTH / 2} // Start in the center
	move_direction = {0, 0}

	// Calculate center of the middle cell in screen coordinates
	center_x := current_player_position.x * CELL_SIZE + CELL_SIZE / 2
	center_y := current_player_position.y * CELL_SIZE + CELL_SIZE / 2

	// Apply zoom factor to convert to screen coordinates
	zoom := f32(WINDOW_SIZE) / CANVAS_SIZE
	screen_x := i32(f32(center_x) * zoom)
	screen_y := i32(f32(center_y) * zoom)

	rl.SetMousePosition(screen_x, screen_y)
	// Reset other game state here
}

// Draw functions
draw_blocks :: proc() {
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_WIDTH {
			block := blocks[x][y]
			block_pos := rl.Vector2 {
				BOARD_OFFSET_X + f32(block.pos[0] * CELL_SIZE),
				BOARD_OFFSET_Y + f32(block.pos[1] * CELL_SIZE),
			}
			if block.status == CellStatus.Active {
				// Draw the cell based on its type
				switch block.type {
				case CellType.Stone:
					rl.DrawTextureV(stone_sprite, block_pos, rl.WHITE)
				case CellType.MossyStone:
					rl.DrawTextureV(mossy_stone_sprite, {f32(block.pos[0]), f32(block.pos[1])} * CELL_SIZE, rl.WHITE)
				case CellType.MossyStoneCracked:
					rl.DrawTextureV(
						mossy_stone_cracked_sprite,
						{f32(block.pos[0]), f32(block.pos[1])} * CELL_SIZE,
						rl.WHITE,
					)
				case CellType.Empty:
				// Do nothing for empty cells
				}
			}
		}
	}
}

draw_background_board :: proc() {
	// Draw big rectangle background with offset
	background_rect := rl.Rectangle{BOARD_OFFSET_X, BOARD_OFFSET_Y, CANVAS_SIZE, CANVAS_SIZE}
	rl.DrawRectangleRec(background_rect, BOARD_COLORS[BoardColors.Background])

	// Draw the board pattern (checkerboard) with offset
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_WIDTH {
			if (x + y) % 2 == 0 {
				rect := rl.Rectangle {
					BOARD_OFFSET_X + f32(x * CELL_SIZE),
					BOARD_OFFSET_Y + f32(y * CELL_SIZE),
					CELL_SIZE,
					CELL_SIZE,
				}
				rl.DrawRectangleRec(rect, BOARD_COLORS[BoardColors.Pattern])
			}
		}
	}

	// Draw grid lines with offset
	for x in 0 ..< GRID_WIDTH + 1 {
		start_pos := rl.Vector2{BOARD_OFFSET_X + f32(x * CELL_SIZE), BOARD_OFFSET_Y}
		end_pos := rl.Vector2{BOARD_OFFSET_X + f32(x * CELL_SIZE), BOARD_OFFSET_Y + CANVAS_SIZE}
		rl.DrawLineEx(start_pos, end_pos, GRID_LINE_WIDTH, BOARD_COLORS[BoardColors.Line])
	}

	for y in 0 ..< GRID_WIDTH + 1 {
		start_pos := rl.Vector2{BOARD_OFFSET_X, BOARD_OFFSET_Y + f32(y * CELL_SIZE)}
		end_pos := rl.Vector2{BOARD_OFFSET_X + CANVAS_SIZE, BOARD_OFFSET_Y + f32(y * CELL_SIZE)}
		rl.DrawLineEx(start_pos, end_pos, GRID_LINE_WIDTH, BOARD_COLORS[BoardColors.Line])
	}
}

// Player movement related functions
get_grid_coordinates_from_mouse :: proc() -> Vec2i {
	mouse_pos := rl.GetMousePosition()
	// Convert to grid coordinates, considering the camera zoom
	zoom := f32(WINDOW_SIZE) / CANVAS_SIZE
	grid_x := int(mouse_pos.x / (CELL_SIZE * zoom))
	grid_y := int(mouse_pos.y / (CELL_SIZE * zoom))

	// Clamp to grid boundaries
	grid_x = max(0, min(grid_x, GRID_WIDTH - 1))
	grid_y = max(0, min(grid_y, GRID_WIDTH - 1))

	return Vec2i{grid_x, grid_y}
}
move_player :: proc() {
	// Calculate new position
	new_pos := Vec2i{current_player_position.x + move_direction.x, current_player_position.y + move_direction.y}

	// Check bounds
	if new_pos.x >= 0 && new_pos.x < GRID_WIDTH && new_pos.y >= 0 && new_pos.y < GRID_WIDTH {
		current_player_position = new_pos
	}

	// Reset movement direction after moving
	move_direction = {0, 0}
}

game_loop :: proc() {
	for !rl.WindowShouldClose() {
		handle_player_mouse_position()
		handle_select_key_input()
		// Game over
		// if all cells are clicked, set game_over to true
		active_blocks := 0
		for x in 0 ..< GRID_WIDTH {
			for y in 0 ..< GRID_WIDTH {
				if blocks[x][y].status == CellStatus.Active {
					active_blocks += 1
				}
			}
		}
		if active_blocks == MAX_GRID_CELLS {
			game_over = true
		}

		if game_over {
			handle_game_over_key_input()
		}
		move_player()


		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		// Camera
		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE) / (CANVAS_SIZE + GRID_LINE_WIDTH),
		}
		rl.BeginMode2D(camera)
		blocks[5][5].type = CellType.Empty
		blocks[5][5].status = CellStatus.Inactive
		

		// Draw grid cell
		draw_background_board()
		draw_blocks()

		// Player
		rl.DrawTextureV(
			player_sprite,
			({f32(current_player_position.x), f32(current_player_position.y)} * CELL_SIZE) + GRID_LINE_OFFSET,
			rl.WHITE,
		)

		rl.DrawText(
			fmt.ctprintf("Position: %d, %d", current_player_position.x, current_player_position.y),
			5,
			5,
			1,
			rl.WHITE,
		)
		rl.DrawText(
			fmt.ctprintf("Status: %v", blocks[current_player_position.x][current_player_position.y].status),
			5,
			15,
			1,
			rl.WHITE,
		)

		rl.EndMode2D()
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Mine It Down!")
	rl.HideCursor()
	//rl.InitAudioDevice()
	defer {
		rl.ShowCursor()
		rl.CloseWindow()
	}
	//defer rl.CloseAudioDevice()
	init_game()
	load_sprites()
	game_loop()

}
