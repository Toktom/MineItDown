package mineitdown

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

// Data structures for texture atlas
Frame :: struct {
	x: int,
	y: int,
	w: int,
	h: int,
}

Size :: struct {
	w: int,
	h: int,
}

Pivot :: struct {
	x: f32,
	y: f32,
}

TextureData :: struct {
	name:             string,
	frame:            Frame,
	rotated:          bool,
	trimmed:          bool,
	spriteSourceSize: Frame,
	sourceSize:       Size,
	pivot:            Pivot,
}

AtlasData :: struct {
	frames: map[string]TextureData,
}

// Main atlas type that encapsulates both texture and data
Atlas :: struct {
	texture: rl.Texture2D,
	data:    AtlasData,
	loaded:  bool,
}

atlas: Atlas

// Initialize the atlas from files in the specified path
init_atlas :: proc() -> bool {
	path := "assets/"
	path_cstr := strings.clone_to_cstring(path)
	defer delete(path_cstr)

	// Load texture
	texture, ok := load_atlas_texture(path_cstr)
	if !ok {
		return false
	}
	atlas.texture = texture

	// Load data
	data := AtlasData{}
	data, ok = load_atlas_data(path_cstr)
	if !ok {
		rl.UnloadTexture(atlas.texture)
		return false
	}

	atlas.data = data
	atlas.loaded = true

	fmt.printfln("Successfully loaded %d textures from atlas", len(atlas.data.frames))
	return true
}

// Check if a file exists at the given path
file_exists :: proc(path: cstring) -> bool {
	exists := rl.FileExists(path)
	if !exists {
		fmt.printfln("File not found: %s", path)
	}
	return exists
}

// Load the texture atlas image
load_atlas_texture :: proc(path: cstring) -> (texture: rl.Texture2D, success: bool) {
	atlas_path := fmt.ctprintf("%s%s", path, "atlas.png")

	if !file_exists(atlas_path) {
		return {}, false
	}

	texture = rl.LoadTexture(atlas_path)
	if texture.id == 0 {
		fmt.println("Failed to load texture atlas")
		return {}, false
	}

	return texture, true
}

// Load and parse the atlas JSON data
load_atlas_data :: proc(path: cstring) -> (data: AtlasData, success: bool) {
	atlas_data_path := fmt.ctprintf("%s%s", path, "atlas.json")

	if !file_exists(atlas_data_path) {
		return {}, false
	}

	atlas_data_file, read_ok := os.read_entire_file_from_filename(string(atlas_data_path))
	if !read_ok {
		fmt.println("Failed to read atlas data file")
		return {}, false
	}
	defer delete(atlas_data_file)

	unmarshal_err := json.unmarshal(atlas_data_file, &data)
	if unmarshal_err != nil {
		fmt.printfln("Failed to unmarshal JSON: %v", unmarshal_err)
		return {}, false
	}

	return data, true
}

// Clean up atlas resources
unload_atlas :: proc() {
	if atlas.loaded {
		rl.UnloadTexture(atlas.texture)
		for _, frame in atlas.data.frames {
			delete(frame.name)
		}
		delete(atlas.data.frames)
		atlas.loaded = false
	}
}

// Get a rectangle for a named texture in the atlas
get_texture_rectangle :: proc(texture_name: string) -> (rect: rl.Rectangle, found: bool) {
	if !atlas.loaded {
		return {}, false
	}

	texture_data, exists := atlas.data.frames[texture_name]
	if !exists {
		fmt.printfln("Texture '%s' not found in atlas", texture_name)
		return {}, false
	}

	return rl.Rectangle {
			f32(texture_data.frame.x),
			f32(texture_data.frame.y),
			f32(texture_data.frame.w),
			f32(texture_data.frame.h),
		},
		true
}

// Legacy function for compatibility
load_texture_from_atlas_as_rectangle :: proc(texture_name: string) -> rl.Rectangle {
	rect, _ := get_texture_rectangle(texture_name)
	return rect
}
