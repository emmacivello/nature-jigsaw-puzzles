extends ColorRect

func _on_shuffle_pressed():
	var chunks = get_tree().get_nodes_in_group("chunk_collider")
	for c in chunks:
		var size = GeneralFuncs.find_chunk_size(c.get_parent())
		var viewport = get_viewport_rect().size
		var pos_x = randi_range(0 - size.min_x, viewport.x - (size.min_x + size.w))
		var pos_y = 50 + randi_range(0 - size.min_y, viewport.y - (size.min_y + size.h) - 50)
		c.get_parent().position = Vector2(pos_x, pos_y)

func _on_mute_pressed():
	if get_node("Mute").texture_normal == load("res://icons/volume-high-solid.svg"):
		get_node("Mute").texture_normal = load("res://icons/volume-xmark-solid.svg")
		get_node("Mute").tooltip_text = "Unmute"
	else:
		get_node("Mute").texture_normal = load("res://icons/volume-high-solid.svg")
		get_node("Mute").tooltip_text = "Mute"
	
	Global.muted = !Global.muted

func _on_home_pressed():
	get_node("../BackToHomeMenu").show()
	get_node("../BackToHomeMenu").scale = Vector2(0,0)
	
	#https://urodelagames.github.io/2021/09/29/godot-tweens-by-example/
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("../BackToHomeMenu"), "scale", Vector2(1,1), 0.2)
	tween.play()
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(get_node("../BackToHomeMenu"), "position", Vector2(360,220), 0.2).from(Vector2(700,24))
	tween2.play()
