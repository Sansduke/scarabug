extends Area2D


# Declare member variables here. Examples:
export var rows = 12
export var columbs = 7
export var item_size = 32
var map = [].append([])
var selected_objects

signal switched_objects

# Called when the node enters the scene tree for the first time.
func _ready():
	rows = 12
	columbs = 7
	item_size = 32
	selected_objects = []
	
	map = []
	for x in range(columbs):
		var y = []
		y.resize(rows)
		map.append(y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func swap_objects():
	pass

func set_object_at(x, y, object):
	map[x][y] = object

func get_object_at(x, y):
	return map[x][y]

func get_spaces():
	return rows * columbs 

func _on_PlayArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print("a click at columb %d row %d"%[event.position.x/item_size,event.position.y/item_size])
		selected_objects.append(get_object_at(event.position.x/item_size-1,event.position.y/item_size-1))
		if selected_objects.size() == 2:
			var firstobject = selected_objects[0]
			set_object_at(firstobject.position.x/item_size-1, firstobject.position.y/item_size-1, selected_objects[1])
			var tempposition = selected_objects[1].position
			selected_objects[1].position = firstobject.position
			firstobject.position = tempposition
			set_object_at(event.position.x/item_size-1, event.position.y/item_size-1, firstobject)
			
			
			
			emit_signal("switched_objects", Vector2(selected_objects[1].position.x/item_size-1, selected_objects[1].position.y/item_size-1), Vector2(firstobject.position.x/item_size-1, firstobject.position.y/item_size-1))
			
			selected_objects.clear()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_RIGHT:
		var testmatches = get_parent().check_for_matches(Vector2(event.position.x/item_size-1,event.position.y/item_size-1))
		for o in testmatches:
			o.set_type(5)
