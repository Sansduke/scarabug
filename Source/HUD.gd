extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var messages = {
	1 : "level 1 \nclick any 2 bugs to swap \nmatch the same colored scarabs in groups of 4 or more" ,
	2 : "level 2 \nbugged scarabs can't be matched during your turn phase \nbut turn back into their color after" ,
	3 : "level 3 \nthe fly can't be matched during your turn phase \nbut combines with other matches after" ,
	4 : "level 4 \nthe mantis can't be matched during your turn phase \nbut eliminate eachother after" ,
	5 : "level 5 \nthe the grub can't be matched during your turn phase \nbut tranforms into a specified color after" ,
	6 : "level 6 \nthe arachnid can't be matched during your turn phase \n" ,
}
var grub_selection
signal start_level
signal undo_last_move
signal grub_selection_made


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_game():
	$ScoreLabel.text = "Score: 0"
	$LevelLabel.text = "Level: 1"

func show_message(mid):
	$MessageLabel.text = messages[mid]
	$MessageLabel.visible = true
	$StartButton.visible = true

func grub_color():
	grub_selection = -1
	$GrubSelectionPanel.show()
	grub_selection = yield($GrubSelectionPanel, "grub_selection_made")
	$GrubSelectionPanel.hide()
	emit_signal("grub_selection_made", grub_selection)

func update_score(score):
	$ScoreLabel.text = "Score: " + str(score)

func update_level(level):
	$LevelLabel.text = "Level: " + str(level)

func update_turns(turns):
	$TurnsLabel.text = str(turns) + " turns left" 

func is_waiting():
	return !$MessageLabel.visible

func _on_StartButton_pressed():
	$MessageLabel.visible = false
	$StartButton.visible = false
	emit_signal("start_level")


func _on_SoundToggleButton_toggled(button_pressed):
	if $SoundToggleButton.pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		$SoundToggleButton.text = "Sound Off"
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		$SoundToggleButton.text = "Sound On"


func _on_UndoButton_pressed():
	emit_signal("undo_last_move")
