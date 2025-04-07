package mineitdown

import rl "vendor:raylib"

grid_to_screen :: proc(grid_pos: Vec2i) -> rl.Vector2 {
    return rl.Vector2{
        BOARD_OFFSET_X + (f32(grid_pos.x) * CELL_SIZE),
        BOARD_OFFSET_Y + (f32(grid_pos.y) * CELL_SIZE),
    }
}

grid_to_screen_center :: proc(grid_pos: Vec2i) -> rl.Vector2 {
    return rl.Vector2{
        BOARD_OFFSET_X + (f32(grid_pos.x) * CELL_SIZE) + (CELL_SIZE / 2),
        BOARD_OFFSET_Y + (f32(grid_pos.y) * CELL_SIZE) + (CELL_SIZE / 2),
    }
}

screen_to_grid :: proc(screen_pos: rl.Vector2) -> Vec2i {
    // Convert to grid coordinates, considering the camera zoom
    zoom := DEFAULT_CAMERA_ZOOM
    
    // Remove board offset and convert to grid coordinates
    grid_x := int((screen_pos.x / zoom - BOARD_OFFSET_X) / CELL_SIZE)
    grid_y := int((screen_pos.y / zoom - BOARD_OFFSET_Y) / CELL_SIZE)
    
    // Clamp to grid boundaries
    grid_x = max(0, min(grid_x, GRID_WIDTH - 1))
    grid_y = max(0, min(grid_y, GRID_HEIGHT - 1))
    
    return Vec2i{grid_x, grid_y}
}

get_grid_coordinates_from_mouse :: proc() -> Vec2i {
    return screen_to_grid(rl.GetMousePosition())
}
