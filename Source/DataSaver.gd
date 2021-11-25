extends Node

var default_data = {"hiscore": 0}

func storeSave(data):
	var savefile = File.new()
	savefile.open("user://scarabug.save", File.WRITE)
	savefile.store_line(to_json(data))
	savefile.close()


func loadSave():
	var savefile = File.new()
	if savefile.file_exists("user://scarabug.save"):
		savefile.open("user://scarabug.save", File.READ)
		var savedata = parse_json(savefile.get_line())
		savefile.close()
		return savedata
	else:
		return default_data
