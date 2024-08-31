extends Node2D

@onready var audio_player = get_node("AudioStreamPlayer2D")

func play_sound(sound):
	audio_player.stream = sound
	audio_player.play()

func _on_play_pressed():
	play_sound(Global.click2)
	await audio_player.finished
	get_tree().change_scene_to_packed(Global.customization_scene)

func _on_howto_pressed():
	play_sound(Global.click2)
	await audio_player.finished
	get_tree().change_scene_to_packed(Global.howto_scene)

func _on_credits_pressed():
	play_sound(Global.click2)
	await audio_player.finished
	get_tree().change_scene_to_packed(Global.credits_scene)
