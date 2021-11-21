extends Area2D


# Declare member variables here. Examples:
export var rows = 12
export var columbs = 7
export var item_size = 50
var map = [].append([])
var selected_objects
var last_switch

signal switched_objects
signal undid_switched_objects

# Called when the node enters the scene tree for the first time.
func _ready():
	rows = 12
	columbs = 7
	item_size = 50
	selected_objects = []
	last_switch = []
	
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reset():
	map = []
	for x in range(columbs):
		var y = []
		y.resize(rows)
		map.append(y)
	
	selected_objects.clear()
	last_switch.clear()

func swap_objects():
	pass

func set_object_at(x, y, object):
	map[x][y] = object

func get_object_at(x, y):
	if x >= map.size() or y >= map[x].size():
		return null
	else:
		return map[x][y]

func get_spaces():
	return rows * columbs 

func _on_PlayArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and get_parent().ready_for_input():
		var relativeposition = event.position - self.position
		var clickindex = Vector2(floor(relativeposition.x/item_size), floor(relativeposition.y/item_size))
		print("a click at columb %d row %d"%[clickindex.x,clickindex.y])
		selected_objects.append(get_object_at(clickindex.x, clickindex.y))
		
		# TODO: if object is aready selected then desecect it instead /////////////////////////////////////
		
		selected_objects.back().set_selected(true)
		if selected_objects.size() >= 2:
			
			var firstobject = selected_objects[0]
			var secondobject = selected_objects[1]
			var firstposition = Vector2(firstobject.position.x, firstobject.position.y)
			var secondposition = Vector2(secondobject.position.x, secondobject.position.y)
			
			firstobject.desired_position = secondposition
			set_object_at(floor(secondposition.x/item_size), floor(secondposition.y/item_size), firstobject)
			secondobject.desired_position = firstposition
			set_object_at(floor(firstposition.x/item_size), floor(firstposition.y/item_size), secondobject)
			
			last_switch = [firstposition, secondposition]
			
			emit_signal("switched_objects", Vector2(floor(firstposition.x/item_size), floor(firstposition.y/item_size)), Vector2(floor(secondposition.x/item_size), floor(secondposition.y/item_size)))
			
			selected_objects[0].set_selected(false)
			selected_objects[1].set_selected(false)
			selected_objects.clear()
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		var testmatches = get_parent().check_for_matches(Vector2(event.position.x/item_size-1,event.position.y/item_size-1))
		for o in testmatches:
			o.set_type(5)


func _on_HUD_undo_last_move():
	if last_switch.size() == 2:
		var firstobject = get_object_at(floor(last_switch[0].x/item_size), floor(last_switch[0].y/item_size))
		var secondobject = get_object_at(floor(last_switch[1].x/item_size), floor(last_switch[1].y/item_size))
		var firstposition = last_switch[0]
		var secondposition = last_switch[1]
			
		firstobject.desired_position = secondposition
		set_object_at(floor(secondposition.x/item_size), floor(secondposition.y/item_size), firstobject)
		secondobject.desired_position = firstposition
		set_object_at(floor(firstposition.x/item_size), floor(firstposition.y/item_size), secondobject)
		
		last_switch.clear()
		
		emit_signal("undid_switched_objects")
