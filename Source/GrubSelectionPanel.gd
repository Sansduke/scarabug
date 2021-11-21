extends Panel


signal grub_selection_made


func _ready():
	pass # Replace with function body.

func _on_ButtonT0_pressed():
	emit_signal("grub_selection_made", 0)

func _on_ButtonT1_pressed():
	emit_signal("grub_selection_made", 1)

func _on_ButtonT2_pressed():
	emit_signal("grub_selection_made", 2)

func _on_ButtonT3_pressed():
	emit_signal("grub_selection_made", 3)
