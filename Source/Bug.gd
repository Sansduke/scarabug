extends Area2D


# Declare member variables here. Examples:
export var playarea_position = Vector2.ZERO

var desired_position
var speed
var bug_type
var selected
var moving

signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_type(0)
	update()
	#bug_type = 0
	selected = false
	speed = 400
	desired_position = position

func set_type(type=0):
	bug_type = type
	if range(0, 4).has(bug_type):
		$Sprite.frame = type
	elif range(4, 8).has(bug_type):
		$Sprite.frame = type
	elif range(8, 12).has(bug_type):
		$Sprite.frame = type

func set_selected(isselected):
	if isselected:
		selected = true
		$Sprite.frame = bug_type + 12
		#turn on selection shader
	else:
		selected = false
		$Sprite.frame = bug_type
		#turn off selection shader

func get_type():
	return bug_type

func get_texture():
	return $Sprite.texture

func clear():
	$ClearParticles.restart()
	$Sprite.visible = false
	$DeletionTimer.start()

func transform():
	$TransformParticles.restart()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if desired_position != position:
		moving = true
		position = position.move_toward(desired_position, speed * delta)
	else:
		moving = false
		
		


#func _on_Bug_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
#		print("bug clicked")


func _on_DeletionTimer_timeout():
	queue_free()
