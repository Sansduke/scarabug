extends Node

export (PackedScene) var Bug

# Declare member variables here.
var bug_types
var matching_types
var score
var score_multiplier
var level
var turns_left


# Called when the node enters the scene tree for the first time.
func _ready():
	bug_types = []
	matching_types = [0, 1, 2, 3]
	randomize()
	startGame()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startGame():
	print("starting game")
	score = 0
	score_multiplier = 1
	level = 1
	$HUD.start_game()
	$HUD.show_message(level)
	

func endGame():
	startGame()

func startLevel():
	$HUD.update_level(level)
	turns_left = 9 + 3*level 
	$HUD.update_turns(turns_left)
	
	bug_types.clear()
	for t in range(0, 4):
		bug_types.append_array([t, t, t, t])
	if level >= 2:
		bug_types.append_array([4, 5, 6, 7])
	if level == 3:
		bug_types.append_array([8, 8])
	elif level == 4:
		bug_types.append_array([9, 9])
	elif level == 5:
		bug_types.append_array([10, 10])
	elif level == 6:
		bug_types.append_array([11, 11])
	
	fillBoard()

func endLevel():
	for b in get_tree().get_nodes_in_group("bugs"):
		var type = b.get_type()
		if range(4, 8).has(type):
			b.set_type(type-4)
	
	#final match
	
	for b in get_tree().get_nodes_in_group("bugs"):
		b.visible = false
		b.queue_free()
	
	level += 1
	$HUD.show_message(level)
	
	if level == 4:
		endGame()


func fillBoard():
	#for i in get_tree().get_nodes_in_group("bugs"):
	#	i.visible = false
	#	i.queue_free()
	
	for rw in range(0, $PlayArea.rows):
		for col in range(0, $PlayArea.columbs):
			var newbug = Bug.instance()
			newbug.playarea_position = Vector2(col, rw)
			
			var possibletypes = bug_types.duplicate()
			possibletypes.shuffle()
			newbug.set_type(possibletypes.pop_front())
			$PlayArea.add_child(newbug)
			$PlayArea.set_object_at(col, rw, newbug)
			newbug.desired_position = Vector2(col*$PlayArea.item_size, rw*$PlayArea.item_size)
	
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

func clear_match(matches):
	#increase score
	score += 10 * (matches.size()-3) * score_multiplier
	$HUD.update_score(score)
	 
	for col in range(0, $PlayArea.columbs): # for each columb
		
		#removed matched bugs
		for mb in matches:
			if $PlayArea.map[col].has(mb):
				$PlayArea.map[col].erase(mb)
				mb.queue_free()

		#add bugs if needed
		while $PlayArea.map[col].size() < $PlayArea.rows:

			var newbug = Bug.instance()
			var possibletypes = bug_types.duplicate()
			possibletypes.shuffle()
			newbug.set_type(possibletypes.pop_front())
			$PlayArea.add_child(newbug)
			$PlayArea.map[col].append(newbug)
			newbug.playarea_position = Vector2(col, $PlayArea.map[col].size())
			
			#move the bug
			newbug.position.x = col * $PlayArea.item_size
			newbug.position.y = $PlayArea.rows * $PlayArea.item_size
			newbug.desired_position = newbug.position
			newbug.desired_position.y = $PlayArea.map[col].size() * $PlayArea.item_size

		#move other bugs
		for b in range($PlayArea.map[col].size()):
			$PlayArea.map[col][b].desired_position.y = b * $PlayArea.item_size

func clear_all_matches():
	var match_was_found = false
	for rw in range(0, $PlayArea.rows):
		for col in range(0, $PlayArea.columbs):
			var potentalmatches = check_for_matches(Vector2(col, rw))
			if potentalmatches.size() > 3:
				match_was_found = true
				clear_match(potentalmatches)
	if match_was_found:
		$SFX1.play()
		$SFX1.pitch_scale += 0.1
		score_multiplier += 1
		$SubMatchTimer.start()
	else:
		$SFX1.pitch_scale = 1.0
		score_multiplier = 1

func ready_for_input():
	if $SubMatchTimer.is_stopped() and $HUD.is_waiting():
		return true
	else:
		return false


func _on_PlayArea_switched_objects(firstposition, secondposition):
	var firstmatches = check_for_matches(firstposition)
	var secondmatches = check_for_matches(secondposition)
	var match_was_found = false
	
	if firstmatches.size() > 3:
		print("matches at first position")
		clear_match(firstmatches)
		match_was_found = true
	if secondmatches.size() > 3:
		print("matches at second position")
		clear_match(secondmatches)
		match_was_found = true
	
	if match_was_found:
		$SFX1.play()
		score_multiplier += 1
		$SubMatchTimer.start()
	else:
		score_multiplier = 1
		
	turns_left -= 1
	$HUD.update_turns(turns_left)
	if turns_left <= 0:
		endLevel()


func _on_SubMatchTimer_timeout():
	var bug_is_moving = false
	for b in get_tree().get_nodes_in_group("bugs"):
		if b.moving == true:
			bug_is_moving = true
	if bug_is_moving:
		$SubMatchTimer.start()
	else:
		clear_all_matches()
