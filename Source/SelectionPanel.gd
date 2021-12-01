extends Panel


signal selection_made


func _ready():
	pass # Replace with function body.

func get_user_input(message):
	$InstructionLabel.text = message
	show()
	
func _on_ButtonT0_pressed():
	emit_signal("selection_made", 0)
	hide()

func _on_ButtonT1_pressed():
	emit_signal("selection_made", 1)
	hide()

func _on_ButtonT2_pressed():
	emit_signal("selection_made", 2)
	hide()

func _on_ButtonT3_pressed():
	emit_signal("selection_made", 3)
	hide()
