extends Panel

@onready var audio_player = get_node("../AudioStreamPlayer2D")

func play_sound(sound):
	audio_player.stream = sound
	audio_player.play()

func _on_home_confirm_pressed():
	play_sound(Global.click3)
	await audio_player.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_home_cancel_pressed():
	play_sound(Global.click3)
	get_node(".").hide()
