extends Node2D

@onready var audio_player = get_node("AudioStreamPlayer2D")

func play_sound(sound):
	audio_player.stream = sound
	audio_player.play()

func _on_back_button_pressed():
	play_sound(Global.click3)
	await audio_player.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
