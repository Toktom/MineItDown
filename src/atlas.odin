package mineitdown

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

Frame :: struct {
	x:      int,
	y:      int,
	w:  int,
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
    name: string,
    frame: Frame,
    rotated: bool,
    trimmed: bool,
    spriteSourceSize: Frame,
    sourceSize: Size,
    pivot: Pivot,
}

AtlasData :: struct {
    frames: map[string]TextureData,
}

atlas_texture: rl.Texture2D
atlas_data: AtlasData

init_atlas :: proc() {
    path := "assets/"
    atlas_texture = load_atlas_texture(strings.clone_to_cstring(path))
    data := load_atlas_raw_data(strings.clone_to_cstring(path))
    
    if data == nil {
        fmt.println("Failed to load atlas data")
        return
    }
    
    // Option 1: Using unmarshal directly into a typed structure
    
    unmarshal_err := json.unmarshal(data, &atlas_data)
    if unmarshal_err != nil {
        fmt.printfln("Failed to unmarshal JSON: %v", unmarshal_err)
        return
    }
    
    fmt.printfln("Successfully loaded %d textures data", len(atlas_data.frames))
    //fmt.println("Raw JSON:", atlas_data.frames["mossy_stone"].frame.w)
}

file_exists :: proc(path: cstring) {
	if !rl.FileExists(path) {
		fmt.printfln("File not found: %s", path)
		return
	} else {
		fmt.printfln("File found: %s", path)
	}
}

load_atlas_texture :: proc(path: cstring) -> rl.Texture2D {
	atlas_path := fmt.ctprintf("%s%s", path, "atlas.png")
	file_exists(atlas_path)
	return rl.LoadTexture(atlas_path)
}

load_atlas_raw_data :: proc(path: cstring) -> []byte {
	atlas_raw_data_path := fmt.ctprintf("%s%s", path, "atlas.json")
	file_exists(path)

	atlas_data_file, err := os.read_entire_file_from_filename(string(atlas_raw_data_path))
	if !err {
		fmt.printfln("Failed to read atlas data file: %s", err)
		return nil
	}
    return atlas_data_file
}

unload_atlas :: proc() {
    rl.UnloadTexture(atlas_texture)
}

load_texture_from_atlas_as_rectangle :: proc(texture_name: string) -> rl.Rectangle {
    return rl.Rectangle{
        f32(atlas_data.frames[texture_name].frame.x),
        f32(atlas_data.frames[texture_name].frame.y),
        f32(atlas_data.frames[texture_name].frame.w),
        f32(atlas_data.frames[texture_name].frame.h),
    }
}