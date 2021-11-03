extends Area2D


# Declare member variables here. Examples:
export var playarea_position = Vector2.ZERO

var bug_type
var selected

signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_type(0)
	update()
	selected = false

func set_type(type=0):
	bug_type = type
	$Sprite.frame = type

func get_type():
	return bug_type

func get_texture():
	return $Sprite.texture



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


#func _on_Bug_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
#		print("bug clicked")
