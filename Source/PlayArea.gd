extends Node2D


# Declare member variables here. Examples:
export var rows = 12
export var columbs = 7
export var item_size = 32
var map = [].append([])


# Called when the node enters the scene tree for the first time.
func _ready():
	rows = 12
	columbs = 7
	item_size = 32
	
	map = []
	for x in range(columbs):
		var y = []
		y.resize(rows)
		map.append(y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_object_at(x, y, object):
	map[x][y] = object

func get_object_at(x, y):
	return map[x][y]

func get_spaces():
	return rows * columbs 
