extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var messages = {
	1 : "Level 1 \n\nClick any 2 bugs to swap. \nMatch the same colored scarabs in groups of 4 or more" ,
	2 : "Level 2 \n\nGlitched scarabs can't be matched during your turn phase \nbut turn back into their color after" ,
	3 : "Level 3 \n\nThe fly can't be matched during your turn phase \nbut combines with other matches after" ,
	4 : "Level 4 \n\nThe mantis can't be matched during your turn phase \nbut eliminate each other after" ,
	5 : "Level 5 \n\nThe the grub can't be matched during your turn phase \nbut tranforms into a specified color after" ,
	6 : "Level 6 \n\nThe arachnid can't be matched during your turn phase. \nEliminates itself and nearby scarabs after" ,
}

var sound_icon1 = preload("res://Assets/Textures/soundon-ico.png")
var sound_icon2 = preload("res://Assets/Textures/soundoff-ico.png")

signal start_level
signal undo_last_move
signal grub_selection_made
signal spider_selection_made


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_game():
	#$ScoreLabel.text = "Score: 0"
	#$LevelLabel.text = "Level: 1"
	pass

func show_message(mid):
	$MessageLabel.text = messages[mid]
	$MessageLabel.visible = true
	$StartButton.visible = true

func grub_color():
	var grub_selection = -1
	$SelectionPanel.get_user_input("What color scarab should the grubs turn in to?")
	grub_selection = yield($SelectionPanel, "selection_made")
	emit_signal("grub_selection_made", grub_selection)

func spider_target():
	var spider_target_color = -1
	$SelectionPanel.get_user_input("What color scarab should the arachnids eliminate?")
	spider_target_color = yield($SelectionPanel, "selection_made")
	emit_signal("spider_selection_made", spider_target_color)

func update_score(score):
	$ScoreValue.text = str(score)

func update_hiscore(score):
	$HiScoreValue.text = str(score)

func update_level(level):
	$LevelValue.text = str(level)

func update_turns(turns):
	$TurnsValue.text = str(turns)

func is_waiting():
	if $MessageLabel.visible or $SelectionPanel.visible:
		return false
	else:
		return true

func _on_StartButton_pressed():
	$MessageLabel.visible = false
	$StartButton.visible = false
	emit_signal("start_level")


func _on_SoundToggleButton_toggled(button_pressed):
	if $SoundToggleButton.pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		$SoundToggleButton.text = "Sound Off"
		$SoundToggleButton.icon = sound_icon2
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		$SoundToggleButton.text = "Sound On"
		$SoundToggleButton.icon = sound_icon1


func _on_UndoButton_pressed():
	emit_signal("undo_last_move")
