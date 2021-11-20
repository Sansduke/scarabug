extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var messages = {
	1 : "level 1" ,
	2 : "level 2" ,
	3 : "level 3" ,
	4 : "level 4" 
}
signal start_level


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
