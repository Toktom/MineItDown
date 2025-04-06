package mineitdown

import rl "vendor:raylib"

// Empty Sprites
player_sprite: rl.Texture2D
stone_sprite: rl.Texture2D
mossy_stone_sprite: rl.Texture2D
mossy_stone_cracked_sprite: rl.Texture2D

// Loading with fallback function
fallback_load_texture :: proc(path: cstring, color: rl.Color = rl.BLUE) -> rl.Texture2D {
	// if the texture fails to load, return a default texture
	// that is a square

	texture := rl.LoadTexture(path)
	if texture.id == 0 {
		texture = rl.LoadTextureFromImage(rl.GenImageColor(16, 16, color))
	}

	return texture
}

// Load and unload sprites
load_sprites :: proc() {
	player_sprite = fallback_load_texture("assets/selection.png")
	stone_sprite = fallback_load_texture("assets/stone.png", BLOCKS_COLORS[CellType.Stone])
	mossy_stone_sprite = fallback_load_texture("assets/mossy_stone.png", BLOCKS_COLORS[CellType.MossyStone])
	mossy_stone_cracked_sprite = fallback_load_texture(
		"assets/mossy_stone_cracked.png",
		BLOCKS_COLORS[CellType.MossyStoneCracked],
	)

}
unload_sprites :: proc() {
	rl.UnloadTexture(player_sprite)
	rl.UnloadTexture(stone_sprite)
	rl.UnloadTexture(mossy_stone_sprite)
	rl.UnloadTexture(mossy_stone_cracked_sprite)
}
