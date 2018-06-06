extends Node

enum GRAVITYDIR {
	 DOWN, UP, LEFT, RIGHT
}

export (GRAVITYDIR) var gravity

func _ready():
	var gdir
	if gravity == GRAVITYDIR.DOWN:
		gdir = Vector2(0, -1)
	elif gravity == GRAVITYDIR.UP:
		gdir = Vector2(0, 1)
	elif gravity == GRAVITYDIR.LEFT:
		gdir = Vector2(1, 0)
	else:
		# Must be right
		gdir = Vector2(-1, 0)
		
	$Player.gdirection = gdir
	
	$Player.external_init()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
