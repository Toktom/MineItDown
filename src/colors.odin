#+feature dynamic-literals
package mineitdown

import rl "vendor:raylib"

// Board colors mapped to keys
BOARD_COLORS_MAP: map[BoardColorType]rl.Color = map[BoardColorType]rl.Color {
	.Line       = rl.Color{16, 0, 7, 255}, // Darker color for the board lines
	.Background = rl.Color{32, 1, 22, 255}, // Background color for the board
	.Pattern    = rl.Color{76, 8, 39, 255}, // Pattern color for the board
}

BLOCKS_COLORS_MAP: map[BlockType]rl.Color = map[BlockType]rl.Color {
	.Stone             = rl.Color{20, 20, 50, 255}, // White for stone blocks
	.MossyStone        = rl.Color{25, 255, 0, 255}, // Green for mossy stone blocks
	.MossyStoneCracked = rl.Color{75, 255, 0, 255}, // Red for cracked mossy stone blocks
	.Empty             = rl.Color{0, 0, 0, 0}, // Transparent for empty blocks
}


INTERACTABLE_COLORS_MAP: map[InteractableType]rl.Color = map[InteractableType]rl.Color {
	.None           = rl.Color{0, 0, 0, 0}, // Transparent for none interactable
	.BombSquare     = rl.Color{255, 0, 0, 255}, // Red for bomb square
	.BombHorizontal = rl.Color{255, 128, 0, 255}, // Orange for bomb horizontal
	.BombVertical   = rl.Color{255, 255, 0, 255}, // Yellow for bomb vertical
	.BombCross      = rl.Color{128, 255, 0, 255}, // Green for bomb cross
	.Gem            = rl.Color{0, 0, 255, 255}, // Blue for gem
	.King           = rl.Color{255, 0, 255, 255}, // Purple for king
	.Door           = rl.Color{255, 255, 255, 255}, // White for door
}
