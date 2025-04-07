package mineitdown

// Enums
BoardColorType :: enum {
	Line,
	Background,
	Pattern,
}
BlockType :: enum {
	Empty,
	Stone,
	MossyStone,
	MossyStoneCracked,
}
BlockState :: enum {
	Active,
	Inactive,
}

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}
