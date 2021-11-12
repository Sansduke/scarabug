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
	print("starting game")
	fillBoard()

func fillBoard():
	for i in get_tree().get_nodes_in_group("bugs"):
		i.queue_free()
	#$Grid.clear()
	
	for rw in range(0, $PlayArea.rows):
		for col in range(0, $PlayArea.columbs):
			var newbug = Bug.instance()
			newbug.playarea_position = Vector2(col, rw)
			newbug.position = Vector2(col*$PlayArea.item_size, rw*$PlayArea.item_size)
			var possibletypes = range(0, 4)
			possibletypes.shuffle()
			newbug.set_type(possibletypes.pop_front())
			$PlayArea.add_child(newbug)
			$PlayArea.set_object_at(col, rw, newbug)
	
	#check for matches already in place after the baord is set up and change the bug type to remove the match if present
	#this needs to be done in a seperate loop so it avoids creatind an unrelated match by switching the type
	for rw in range(0, $PlayArea.rows):
		for col in range(0, $PlayArea.columbs):
			var possibletypes = range(0, 4)
			while check_for_matches(Vector2(col, rw)).size() > 3:
				var switchbug = $PlayArea.get_object_at(col, rw)
				print("match at %d , %d type %d"%[col, rw, switchbug.get_type()])
				switchbug.set_type(possibletypes.pop_front())


func check_for_matches(atposition):
	var matchstack = []
	matchstack.clear()
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
	




func _on_PlayArea_switched_objects(firstposition, secondposition):
	var firstmatches = check_for_matches(firstposition)
	var secondmatches = check_for_matches(secondposition)
	
	if firstmatches.size() > 3:
		print("matches at first position")
	if secondmatches.size() > 3:
		print("matches at second position")
