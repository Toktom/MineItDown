package mineitdown

import "core:math/rand"
import rl "vendor:raylib"
Level :: struct {
	level:         int,
    level_var:    f32, // Level variable for difficulty scaling
	width:         int, // Grid width for this specific level
	height:        int, // Grid height for this specific level
	grid_cells:    Grid2i,
	interactables: Interactables2i,
	blocks:        Blocks2i,
}

get_current_level :: proc() -> ^Level {
	return &game_state.current_level
}

init_level :: proc(level_number: int, width: int, height: int) {
	current_level := get_current_level()
	current_level^ = {} // Clear using pointer dereference
	current_level.level = level_number
    current_level.level_var = 0.0
	current_level.width = width
	current_level.height = height

	GRID_WIDTH = width
	GRID_HEIGHT = height
	MAX_GRID_CELLS = width * height

	update_grid_constants()

	current_level.grid_cells = init_grid_cells()
	current_level.interactables = init_interactables(&current_level.grid_cells)
	current_level.blocks = init_blocks(&current_level.grid_cells)
}

update_grid_constants :: proc() {
	MAX_BOARD_SIZE = WINDOW_SIZE_PX * 0.8
	MAX_CELL_SIZE = f32(f32(MAX_BOARD_SIZE) / f32(max(GRID_WIDTH, GRID_HEIGHT)))
	CELL_SIZE = f32(MAX_CELL_SIZE)

	BOARD_SIZE_WIDTH = f32(GRID_WIDTH) * CELL_SIZE
	BOARD_SIZE_HEIGHT = f32(GRID_HEIGHT) * CELL_SIZE

	BOARD_OFFSET_X = (WINDOW_SIZE_PX - BOARD_SIZE_WIDTH) / 2
	BOARD_OFFSET_Y = (WINDOW_SIZE_PX - BOARD_SIZE_HEIGHT) / 2
}

init_level_0 :: proc() {
	init_level(0, 3, 3)
	set_interactable_type(1, 1, InteractableType.BombSquare)
	set_interactable_type(0, 2, InteractableType.Door)
}

load_next_level :: proc() {
	generate_level(get_current_level())
}

generate_level :: proc(current_level: ^Level) {
    level_number := current_level.level + 1
    level_var := current_level.level_var
	if level_number % 10 == 0 {
		level_var = f32(level_number) / 10
	} else {
		level_var = f32(level_number) / 10 + 1
	}

	new_max_grid_width := int(MAX_GRID_WIDTH + level_var)
	new_max_grid_height := int(MAX_GRID_HEIGHT + level_var)
	new_min_grid_width := int(MIN_GRID_WIDTH + level_var)
	new_min_grid_height := int(MIN_GRID_HEIGHT + level_var)

	GRID_WIDTH = rand.int_max(new_max_grid_width - new_min_grid_width) + new_min_grid_width
	GRID_HEIGHT = rand.int_max(new_max_grid_height - new_min_grid_height) + new_min_grid_height

	init_level(level_number, GRID_WIDTH, GRID_HEIGHT)
	set_mossy_stone_at_random_position()
    set_door_at_random_position()
    set_bombs_at_random_position_in_level(current_level)
}

set_door_at_random_position :: proc() {
    door_x := rand.int_max(GRID_WIDTH - 1)
    door_y := rand.int_max(GRID_HEIGHT - 1)
    set_interactable_type(door_x, door_y, InteractableType.Door)
}

set_bombs_at_random_position_in_level :: proc(curent_level: ^Level) {
    chunk_size := 3 + int(curent_level.level_var)
    
    chunks_horizontal := (GRID_WIDTH + chunk_size - 1) / chunk_size
    chunks_vertical := (GRID_HEIGHT + chunk_size - 1) / chunk_size
    
    for chunk_x in 0..<chunks_horizontal {
        for chunk_y in 0..<chunks_vertical {
            if rand.int_max(2) == 0 {
                start_x := chunk_x * chunk_size
                start_y := chunk_y * chunk_size
                end_x := min(start_x + chunk_size, GRID_WIDTH)
                end_y := min(start_y + chunk_size, GRID_HEIGHT)
                
                if start_x >= GRID_WIDTH || start_y >= GRID_HEIGHT || end_x <= start_x || end_y <= start_y {
                    continue
                }
                
                for attempt in 0..<10 {
                    pos_x := start_x + rand.int_max(end_x - start_x)
                    pos_y := start_y + rand.int_max(end_y - start_y)
                    
                    if get_interactable(pos_x, pos_y).status == State.Inactive {
                        set_random_bomb_at_position(pos_x, pos_y)
                        break
                    }
                }
            }
        }
    }
}

set_random_bomb_at_position :: proc(x: int, y: int) {
    bomb_types := [4]InteractableType{
        .BombSquare,
        .BombHorizontal,
        .BombVertical,
        .BombCross,
    }
    bomb_type := bomb_types[rand.int_max(len(bomb_types))]
    set_interactable_type(x, y, bomb_type)
}

set_mossy_stone_at_random_position :: proc() {
	// set mossy stone at random position but a max of 10% of the grid
	mossy_stone_count := int(f32(GRID_WIDTH * GRID_HEIGHT) * 0.3)
	for i in 0 ..< mossy_stone_count {
		x := rand.int_max(GRID_WIDTH - 1)
		y := rand.int_max(GRID_HEIGHT - 1)
		set_block_type(x, y, BlockType.MossyStone)
	}
}