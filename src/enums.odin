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
State :: enum {
	Active,
	Inactive,
}

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

InteractableType :: enum {
	None,
	BombSquare,
	BombHorizontal,
	BombVertical,
	BombCross,
	Gem,
	King,
	Door
}
