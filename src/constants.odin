package mineitdown

// Constants
WINDOW_SIZE :: 1000
// Board grid
GRID_WIDTH :: 5
GRID_HEIGHT :: 5
MAX_GRID_CELLS :: GRID_WIDTH * GRID_HEIGHT

// Calculate cell size based on available space and grid dimensions
// Use the smaller dimension to ensure board fits both horizontally and vertically
MAX_BOARD_SIZE :: WINDOW_SIZE * 0.8  // Use 80% of window size for the board
MAX_CELL_SIZE :: f32(MAX_BOARD_SIZE / f32(max(GRID_WIDTH, GRID_HEIGHT)))
CELL_SIZE :: f32(MAX_CELL_SIZE)

BOARD_WIDTH :: f32(GRID_WIDTH) * CELL_SIZE
BOARD_HEIGHT :: f32(GRID_HEIGHT) * CELL_SIZE

// Line
GRID_LINE_WIDTH :: f32(CELL_SIZE / 12) 
GRID_LINE_OFFSET :: GRID_LINE_WIDTH / 2

// Center the board in the screen
BOARD_OFFSET_X :: (WINDOW_SIZE - BOARD_WIDTH) / 2
BOARD_OFFSET_Y :: (WINDOW_SIZE - BOARD_HEIGHT) / 2

// Camera
DEFAULT_CAMERA_ZOOM :: f32(1.0)  // Reset zoom to 1.0 since we're scaling the board directly


// Texture sizes
TEXTURE_SIZE :: 16