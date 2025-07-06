extends Node

## Shapes the plane can be
enum PlaneTypes {
	NONE,
	L,
	O,
	S,
	BACKWARD_S,
	SMALL_C,
	LARGE_C,
	SMALL_X,
	LARGE_X,
	LOPSIDED_L,
	TRI,
	NUNCHUCK,
	FILLED_O
}

## Which category a level falls into
enum LevelTypes {
	MAIN,
	BONUS,
	HELL,
	CIRCUIT,
	TUTORIAL
}
