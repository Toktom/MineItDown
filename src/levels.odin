package mineitdown

import rl "vendor:raylib"

Level :: struct {
    level: int,
    grid_cells:    Grid2i,
	interactables: Interactables2i,
	blocks:        Blocks2i,
}

// Consider adding this helper
get_current_level :: proc() -> ^Level {
    return &game_state.current_level
}

init_level :: proc(level: int) {
    current_level := get_current_level()
    current_level^ = {} // Clear using pointer dereference
    current_level.level = level

    current_level.grid_cells = init_grid_cells()
    current_level.interactables = init_interactables(&current_level.grid_cells)
    current_level.blocks = init_blocks(&current_level.grid_cells)
}