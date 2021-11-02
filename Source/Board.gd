extends Node

export (PackedScene) var Bug

# Declare member variables here.
var matching_types


# Called when the node enters the scene tree for the first time.
func _ready():
	#for item in $playArea.get_children():
	#	$Grid.clear
	#	$Grid.add_item("", )
	matching_types = [0, 1, 2, 3]
	randomize()
	startGame()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startGame():
	fillBoard()

func fillBoard():
	for i in $PlayArea.get_children():
		i.queue_free()
	
	for rw in range(0, $PlayArea.rows):
		for col in range(0, $PlayArea.columbs):
			var newbug = Bug.instance()
			newbug.playarea_position = Vector2(col, rw)
			newbug.position = Vector2(col*$PlayArea.item_size, rw*$PlayArea.item_size)
			newbug.set_type(0)
			$PlayArea.add_child(newbug)
			$PlayArea.set_object_at(col, rw, newbug)
			#newbug.update()
			#newbug.show()
			while check_for_matches(Vector2(col, rw)).size() > 3:
				print("match at %d , %d type %d"%[col, rw, newbug.get_type()])
				newbug.set_type(randi()%4)
				


func check_for_matches(atposition):
	var matchstack = []
	var bugtype = $PlayArea.get_object_at(atposition.x, atposition.y).get_type()
	if bugtype == null:
		return []
	if matching_types.has(bugtype):
		find_matches(atposition, bugtype, matchstack)
		return matchstack
	else:
		return []

func check_for_matches_full(atpostion):
	var bestmatchlength = 0
	var bestmatchposition = Vector2(0, 0)
	var bestmatchstack = []
	
	for rw in range(0, $PlayArea.rows):
		for col in range(0, $PlayArea.columbs):
			var matchstack = []
			find_matches(Vector2(rw, col), 0, matchstack)
			
			if matchstack.size() > bestmatchlength:
				bestmatchlength = matchstack.size()
				bestmatchposition = [col, rw]
				bestmatchstack = matchstack




func find_matches(atposition, matchtype, activestack):
	var active = $PlayArea.get_object_at(atposition.x, atposition.y)
	activestack.append(active)
	
	#north
	if atposition.y > 0:
		var posibility = $PlayArea.get_object_at(atposition.x, atposition.y-1)
		if posibility == null:
			return
		if posibility.get_type() == matchtype and !activestack.has(posibility):
			find_matches(Vector2(atposition.x, atposition.y-1), matchtype, activestack)
	
	#south
	if atposition.y < $PlayArea.rows-1:
		var posibility = $PlayArea.get_object_at(atposition.x, atposition.y+1)
		if posibility == null:
			return
		if posibility.get_type() == matchtype and !activestack.has(posibility):
			find_matches(Vector2(atposition.x, atposition.y+1), matchtype, activestack)
	
	#east
	if atposition.x < $PlayArea.columbs-1:
		var posibility = $PlayArea.get_object_at(atposition.x+1, atposition.y)
		if posibility == null:
			return
		if posibility.get_type() == matchtype and !activestack.has(posibility):
			find_matches(Vector2(atposition.x+1, atposition.y), matchtype, activestack)
	
	#west
	if atposition.x > 0:
		var posibility = $PlayArea.get_object_at(atposition.x-1, atposition.y)
		if posibility == null:
			return
		if posibility.get_type() == matchtype and !activestack.has(posibility):
			find_matches(Vector2(atposition.x-1, atposition.y), matchtype, activestack)
	
	return
	
