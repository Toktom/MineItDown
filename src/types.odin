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

Movement_Vectors :: [Direction][2]int {
	.Up = {0, -1},
	.Down = {0, 1},
	.Left = {-1, 0},
	.Right = {1, 0},
}