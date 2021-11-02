extends Area2D


# Declare member variables here. Examples:
export var playarea_position = Vector2.ZERO

var bug_type

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_type(0)
	update()

func set_type(type=0):
	bug_type = type
	$Sprite.frame = type

func get_type():
	return bug_type

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
