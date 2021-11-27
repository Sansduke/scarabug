extends Node

export (PackedScene) var Bug

# Declare member variables here.
var bug_types
var matching_types
var score
var score_multiplier
var hiscore
var level
var turns_left
var is_final_move


# Called when the node enters the scene tree for the first time.
func _ready():
	bug_types = []
	matching_types = [0, 1, 2, 3]
	randomize()
	startGame()
	

func startGame():
	print("starting game")
	score = 0
	score_multiplier = 1
	level = 1
	
	$HUD.update_score(score)
	
	hiscore = 0 #incase save file is corrupt
	hiscore = $DataSaver.loadSave()["hiscore"]
	$HUD.update_hiscore(hiscore)
	
	$HUD.start_game()
	$HUD.show_message(level)
	

func endGame():
	if score > hiscore:
		$SFX4.play()
		$DataSaver.storeSave({"hiscore": score})
	startGame()

func startLevel():
	is_final_move = false
	$HUD.update_level(level)
	if level == 1:
		turns_left = 6
	else:
		turns_left = 6 + 2*level
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
	var bug_is_moving = false
	for b in get_tree().get_nodes_in_group("bugs"):
		if b.moving == true:
			bug_is_moving = true
	if bug_is_moving:
		$LevelDelayTimer.start()
	else:
		for b in get_tree().get_nodes_in_group("bugs"):
			b.visible = false
			b.queue_free()
	
		level += 1
		$HUD.show_message(level)
	
		if level == 6:
			endGame()


func fillBoard():
	$PlayArea.reset()
	
	#place bugs on a board
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
	
	#check for matches already in place after the board is set up and change the bug type to remove the match if present
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
	var bugat = $PlayArea.get_object_at(atposition.x, atposition.y)
	if bugat == null or !is_instance_valid(bugat):
		return []
	var bugtype = bugat.get_type()
	if bugtype == null:
		return []
	if matching_types.has(bugtype):
		if is_final_move:
			find_matches(atposition, [bugtype, 8], matchstack)
		else:
			find_matches(atposition, [bugtype], matchstack)
		return matchstack
	else:
		return []


func find_matches(atposition, matchtypes, activestack):
	var active = $PlayArea.get_object_at(atposition.x, atposition.y)
	activestack.append(active)
	
	#north
	if atposition.y > 0:
		var posibility = $PlayArea.get_object_at(atposition.x, atposition.y-1)
		if posibility == null:
			return
		if matchtypes.has(posibility.get_type()) and !activestack.has(posibility):
			find_matches(Vector2(atposition.x, atposition.y-1), matchtypes, activestack)
	
	#south
	if atposition.y < $PlayArea.rows-1:
		var posibility = $PlayArea.get_object_at(atposition.x, atposition.y+1)
		if posibility == null:
			return
		if matchtypes.has(posibility.get_type()) and !activestack.has(posibility):
			find_matches(Vector2(atposition.x, atposition.y+1), matchtypes, activestack)
	
	#east
	if atposition.x < $PlayArea.columbs-1:
		var posibility = $PlayArea.get_object_at(atposition.x+1, atposition.y)
		if posibility == null:
			return
		if matchtypes.has(posibility.get_type()) and !activestack.has(posibility):
			find_matches(Vector2(atposition.x+1, atposition.y), matchtypes, activestack)
	
	#west
	if atposition.x > 0:
		var posibility = $PlayArea.get_object_at(atposition.x-1, atposition.y)
		if posibility == null:
			return
		if matchtypes.has(posibility.get_type()) and !activestack.has(posibility):
			find_matches(Vector2(atposition.x-1, atposition.y), matchtypes, activestack)
	
	return

func clear_match(matches):
	#cant undo anymore
	$PlayArea.last_switch.clear()
	
	#increase score
	score += 10 * max(1, (matches.size()-3)) * score_multiplier * level
	$HUD.update_score(score)
	 
	for col in range(0, $PlayArea.columbs): # for each columb
		
		#removed matched bugs
		for mb in matches:
			if $PlayArea.map[col].has(mb):
				$PlayArea.map[col].erase(mb)
				mb.clear()
				

		# add more bugs if this columb is missing bugs
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
		$SFX1.play() #play match sound again and increase pitch
		$SFX1.pitch_scale += 0.1
		score_multiplier += 1
		$SubMatchTimer.start()
	else:
		$SFX1.pitch_scale = 1.0
		score_multiplier = 1

func ready_for_input():
	if $SubMatchTimer.is_stopped() and $HUD.is_waiting() and $FinalMoveTimer.is_stopped() and $LevelDelayTimer.is_stopped():
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
		$SFX1.play() #play match sound
		score_multiplier += 1
		$SubMatchTimer.start()
	else:
		score_multiplier = 1
		
	turns_left -= 1
	$HUD.update_turns(turns_left)
	if turns_left <= 0:
		$SFX2.play() #play end of level sound
		$FinalMoveTimer.start()


func _on_SubMatchTimer_timeout():
	var bug_is_moving = false
	for b in get_tree().get_nodes_in_group("bugs"):
		if b.moving == true:
			bug_is_moving = true
	if bug_is_moving:
		$SubMatchTimer.start()
	else:
		clear_all_matches()


func finalMove():
	is_final_move = true
	bug_types = [0, 1, 2, 3] #only place the main types on the last move
	
	var grubtype
	if level == 5:
		$HUD.grub_color()
		grubtype = yield($HUD, "grub_selection_made") #yeild to get input from player on grub type
	
	for b in get_tree().get_nodes_in_group("bugs"):
		var type = b.get_type()
		if range(4, 8).has(type): #glitched
			b.set_type(type-4)
			b.transform()
		if type == 8: #fly
			continue
		elif type == 9: #mantis
			var mantisstack = []
			find_matches(Vector2(floor(b.position.x/$PlayArea.item_size), floor(b.position.y/$PlayArea.item_size)), [9], mantisstack)
			if mantisstack.size() > 1:
				print("clear manti") #todo clearing to many manti ????
				clear_match(mantisstack)
		elif type == 10: #grub
			b.set_type(grubtype)
			b.transform()
		elif type == 11: #arachnid
			continue
	
	if level > 1:
		$SFX3.play() #play final move sound
	$FinalClearTimer.start()

func finalClear():
	clear_all_matches()
	$LevelDelayTimer.start()

func _on_PlayArea_undid_switched_objects():
	turns_left += 1
	$HUD.update_turns(turns_left)
	
