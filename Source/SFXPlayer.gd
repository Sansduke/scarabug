extends Node


var sounds = {	"match" : preload("res://Assets/Audio/523763__matrixxx__select-granted-06.wav") ,
				"levelend" : preload("res://Assets/Audio/267528__syseq__good.wav") ,
				"scarab" : preload("res://Assets/Audio/146732__leszek-szary__creature.wav") ,
				"spider" : preload("res://Assets/Audio/561310__badoink__dead-end.wav") ,
				"hiscore" : preload("res://Assets/Audio/462089__newagesoup__ethereal-woosh.wav")
			}

var volume = 0.0
var pitch = 1.0

signal stream_finished

func _ready():
	pass # Replace with function body.


func play_sound(soundname):
	if sounds.has(soundname):
		var audio_stream_player = AudioStreamPlayer.new()
		audio_stream_player.stream = sounds[soundname]
		audio_stream_player.volume_db = volume
		audio_stream_player.pitch_scale = pitch
		audio_stream_player.play()
		audio_stream_player.connect("finished", audio_stream_player, "queue_free")
		audio_stream_player.connect("finished", self, "stream_finished")
		add_child(audio_stream_player)

func stream_finished():
	emit_signal("stream_finished")
