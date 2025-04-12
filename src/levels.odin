package mineitdown

import rl "vendor:raylib"

Level :: struct {
    level: int,
    width: int,  // Grid width for this specific level
    height: int, // Grid height for this specific level
    grid_cells:    Grid2i,
    interactables: Interactables2i,
    blocks:        Blocks2i,
}

// Consider adding this helper
get_current_level :: proc() -> ^Level {
    return &game_state.current_level
}

init_level :: proc(level_number: int, width: int, height: int) {
    current_level := get_current_level()
    current_level^ = {} // Clear using pointer dereference
    current_level.level = level_number
    current_level.width = width
    current_level.height = height

    // Update global variables for grid size
    GRID_WIDTH = width
    GRID_HEIGHT = height
    MAX_GRID_CELLS = width * height
    
    // Update size-dependent constants
    update_grid_constants()
    
    current_level.grid_cells = init_grid_cells()
    current_level.interactables = init_interactables(&current_level.grid_cells)
    current_level.blocks = init_blocks(&current_level.grid_cells)
}

// Helper to update all derived constants based on grid dimensions
update_grid_constants :: proc() {
    // Calculate cell size based on available space and grid dimensions
    MAX_BOARD_SIZE = WINDOW_SIZE_PX * 0.8
    MAX_CELL_SIZE = f32(f32(MAX_BOARD_SIZE) / f32(max(GRID_WIDTH, GRID_HEIGHT)))
    CELL_SIZE = f32(MAX_CELL_SIZE)
    
    BOARD_SIZE_WIDTH = f32(GRID_WIDTH) * CELL_SIZE
    BOARD_SIZE_HEIGHT = f32(GRID_HEIGHT) * CELL_SIZE
    
    // Center the board in the screen
    BOARD_OFFSET_X = (WINDOW_SIZE_PX - BOARD_SIZE_WIDTH) / 2
    BOARD_OFFSET_Y = (WINDOW_SIZE_PX - BOARD_SIZE_HEIGHT) / 2
}

init_level_0 :: proc() {
    init_level(0, 3, 3) // Small 3x3 grid for level 0
    set_interactable_type(1, 1, InteractableType.BombSquare)
    set_interactable_type(0, 2, InteractableType.Door)
}

init_level_1 :: proc() {
    init_level(1, 5, 5) // Larger 5x5 grid for level 1
    // Place a bomb cross in the middle
    set_interactable_type(2, 2, InteractableType.BombCross)
    // Add some stone blocks
    set_block_type(0, 0, BlockType.MossyStone)
    set_block_type(4, 4, BlockType.MossyStone)
    set_interactable_type(0, 1, InteractableType.Door)
}

init_level_2 :: proc() {
    init_level(2, 7, 4) // A 7x4 rectangular grid
    // Add a horizontal bomb
    set_interactable_type(3, 2, InteractableType.BombHorizontal)
    // Add vertical bomb
    set_interactable_type(5, 1, InteractableType.BombVertical)
    // Add some hard blocks
    set_block_type(1, 1, BlockType.MossyStone)
    set_block_type(6, 3, BlockType.MossyStone)
}

// Load a specific level by number
load_level :: proc(level_number: int) {
    switch level_number {
    case 0:
        init_level_0()
    case 1:
        init_level_1()
    case 2:
        init_level_2()
}
}