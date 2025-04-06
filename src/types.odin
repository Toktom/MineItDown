package mineitdown

Vec2i :: [2]int
Vec2f :: [2]f32
Cell :: struct {
	pos: Vec2i,
}

Block :: struct {
	using cell: Cell,
	status:     CellStatus,
	type:       CellType,
}
