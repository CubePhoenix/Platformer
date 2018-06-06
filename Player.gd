extends KinematicBody2D

var startpoint
var zone
var zone_version
var gdirection

#########################################################
#														#
#					Initialization						#
#														#
#########################################################

# This function must be called from the scene itself
# in order to ensure execution after setting the 
# gdirection variable
func external_init():
	startpoint = position
	
	if (gdirection == Vector2(0, 1)):
		$Sprite.flip_v = true
	elif (gdirection == Vector2(-1, 0)):
		$Sprite.rotate(-1.5)
	elif (gdirection == Vector2(1, 0)):
		$Sprite.rotate(1.5)
		
	# Define death zone
	if (gdirection == Vector2(0, -1)):
		zone = DEATH_ZONE_DOWN
		zone_version = false
	elif (gdirection == Vector2(0, 1)):
		zone = DEATH_ZONE_UP
		zone_version = true
	elif (gdirection == Vector2(1, 0)):
		zone = DEATH_ZONE_LEFT
		zone_version = true
	else:
		zone = DEATH_ZONE_RIGHT
		zone_version = false
	
	


#########################################################
#														#
#						Physics							#
#														#
#########################################################

const RUN_MAX_SPEED = 400
const WALK_MAX_SPEED = 200
const RUN_ACCELERATION = 25
const WALK_ACCELERATION = 25
const GRAVITY = 20
const JUMP = -500

const DEATH_ZONE_DOWN = 1000
const DEATH_ZONE_UP = -1000
const DEATH_ZONE_RIGHT = 5000
const DEATH_ZONE_LEFT = 0

enum Shape {
	NORMAL,
	WALK,
	SLIDE
}

var motion = Vector2()
var is_sliding = false

func _physics_process(delta):
	# Be sure the player isn't in an invalid position
	if (zone_version):
		if (get_vertical_pos() < zone):
			_reset_level()
	else:
		if (get_vertical_pos() > zone):
			_reset_level()
	
	set_vertical_motion(get_vertical_motion() + GRAVITY)
	#motion.y += GRAVITY
	
	var friction = false
	
	if (Input.is_action_pressed("ui_right")):
		# Move to the right
		move(true)
		
	elif (Input.is_action_pressed("ui_left")):
		# Move to the left
		move(false)
		
	else:
		friction = true
		
		
		# Play animation
		if (is_on_floor()):
			set_shape(Shape.NORMAL)
			$Sprite.play("Idle")
		elif ($Sprite.get_animation() != "Jump" and $Sprite.get_animation() != "Fall" and
				get_vertical_motion() > GRAVITY*5):
			$Sprite.play("Fall")
			is_sliding = false
	
	if (is_on_floor()):
		if (Input.is_action_pressed("ui_up")):
			# Flip the vector because we want to go up
			motion = motion + multiply_vector(flip_vector(gdirection), JUMP)
			$Sprite.play("Jump")
	elif (get_vertical_motion() > GRAVITY*5):
		$Sprite.play("Fall")
		is_sliding = false
		
	if (friction):
		# Linear interpolation used to simulate friction
		set_horizontal_motion(lerp(get_horizontal_motion(), 0, 0.3))
	#else:
		# Linear interpolation used to simulate friction
		#set_horizontal_motion(lerp(get_horizontal_motion(), 0, 0.02))
	
	# Reset motion if collided (Also say which way is up)
	motion = move_and_slide(motion, gdirection)
	
func move(right):
	
	var flip = false
	
	if (not right):
		flip = true
	
	if (gdirection == Vector2(-1, 0)):
		flip = not flip
		
	$Sprite.flip_h = flip
	
	var acc
	var maxspeed
	var jmaxspeed = WALK_MAX_SPEED
	
	# Play animation
	if (is_on_floor()):
		if (Input.is_action_just_pressed("ui_down") and abs(get_horizontal_motion()) > 5):
			is_sliding = true
			set_shape(Shape.SLIDE)
			$Sprite.play("Slide")
			acc = 0
			maxspeed = RUN_MAX_SPEED
			set_horizontal_motion(lerp(get_horizontal_motion(), 0, 0.0005))
			
		elif (Input.is_action_just_released("ui_down")):
			is_sliding = false
			set_shape(Shape.NORMAL)
			$Sprite.play("Idle")
			acc = 0
			maxspeed = WALK_MAX_SPEED
			
		elif (Input.is_action_pressed("ui_sprint") and not is_sliding):
			set_shape(Shape.NORMAL)
			$Sprite.play("Run")
			acc = RUN_ACCELERATION
			maxspeed = RUN_MAX_SPEED
			
		elif not is_sliding :
			set_shape(Shape.WALK)
			
			$Sprite.play("Walk")
			acc = WALK_ACCELERATION
			maxspeed = WALK_MAX_SPEED
			
		else:
			# Must be sliding
			acc = 0
			maxspeed = RUN_MAX_SPEED
			
	else:
		acc = WALK_ACCELERATION
		maxspeed = max(abs(get_horizontal_motion()), jmaxspeed)
		jmaxspeed = maxspeed
	
	if (not Input.is_action_pressed("ui_down") and is_sliding):
			is_sliding = false
	
	if (right):
		set_horizontal_motion(min(get_horizontal_motion() + acc, maxspeed))
	else:
		set_horizontal_motion(max(get_horizontal_motion() - acc, -maxspeed))

func set_shape(name):
	
	$NormalCShape.disabled = true
	$WalkCShape.disabled = true
	$SlideCShape.disabled = true
	
	if name == Shape.NORMAL:
		$NormalCShape.disabled = false
	elif name == Shape.WALK: 
		
		$WalkCShape.disabled = false
		
	elif name == Shape.SLIDE:
		# Teleport to ground (So player doesn't fall to ground)
		set_vertical_pos(get_vertical_pos() + 12)
			
		$SlideCShape.disabled = false

func flip_vector(vec):
	return Vector2(vec.x * -1, vec.y * -1)
	
func multiply_vector(vec, factor):
	return Vector2(vec.x * factor, vec.y * factor)
	
func get_vertical_motion():
	if gdirection.x == 0:
		return motion.y * gdirection.y * -1
	else:
		return motion.x * gdirection.x * -1
		
func set_vertical_motion(intmotion):
	if gdirection.x == 0:
		motion.y = intmotion * gdirection.y * -1
	else:
		motion.x = intmotion * gdirection.x * -1

func get_horizontal_motion():
	if gdirection.x == 0:
		return motion.x
	else:
		return motion.y

func set_horizontal_motion(intmotion):
	if gdirection.x == 0:
		motion.x = intmotion
	else:
		motion.y = intmotion
		
func get_vertical_pos():
	if gdirection.x == 0:
		return position.y
	else:
		return position.x

func get_horizontal_pos():
	if gdirection.x == 0:
		return position.y
	else:
		return position.x
		
func set_vertical_pos(intpos):
	if gdirection.x == 0:
		position.y = intpos
	else:
		position.x = intpos

func set_horizontal_pos(intpos):
	if gdirection.x == 0:
		position.y = intpos
	else:
		position.x = intpos

#########################################################
#														#
#						Other							#
#														#
#########################################################

func _reset_level():
	position = startpoint
	motion = Vector2(0, 0)
	$Camera.align()
	# TODO dramatic death