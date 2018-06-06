extends ParallaxBackground

export (String, FILE, "*.png") var imgFile

func _ready():
	var img = Image.new()
	var itex = ImageTexture.new()
	img.load(imgFile)
	itex.create_from_image(img, 2)
	
	$ParallaxLayer/Sprite.texture = itex
	$ParallaxLayer.motion_mirroring = img.get_size()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
