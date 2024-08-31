extends Node2D

var img_folder_path = "res://images-puzzles"

func play_sound(sound):
	var audio_player = get_node("AudioStreamPlayer2D")
	audio_player.stream = sound
	audio_player.play()

func make_img_button(width, img):
	var new_button = TextureButton.new()
	new_button.ignore_texture_size = true
	new_button.texture_normal = img
	new_button.stretch_mode = TextureButton.STRETCH_SCALE
	new_button.custom_minimum_size = Vector2(width, 140)
	
	new_button.connect("pressed", Callable(_on_img_button_pressed).bind(new_button, img))
	
	return new_button

func make_button_border(w):
	var panel = PanelContainer.new()
	panel.size.x = w
	panel.size.y = 140
	
	var stylebox = StyleBoxFlat.new()
	stylebox.border_color = Color(1.0, 1.0, 1.0)
	stylebox.bg_color = Color(0,0,0,0)
	stylebox.set_border_width_all(4)
	
	panel.add_theme_stylebox_override("panel", stylebox)
	return panel

func make_img_buttons():
	var total_w = 0
	for i in Global.imgs:
		var w = 140 * (float(i.get_width()) / float(i.get_height()))
		total_w += w
		
		var new_button = make_img_button(w, i)
		var new_button_border = make_button_border(w)
		
		new_button.add_child(new_button_border)
		get_node("ButtonsContainer").add_child(new_button)
	
	var first_button = get_node("ButtonsContainer").get_child(0)
	first_button.button_pressed = true
	_on_img_button_pressed(first_button, Global.imgs[0])
	
	# Not using scroll box around buttons anymore, just using fewer images so 
	# they don't need to scroll - couldn't get around this issue: https://github.com/godotengine/godot/issues/45084

func _on_img_button_pressed(button, i):
	Global.img = i
	
	# radio button behavior
	for b in get_node("ButtonsContainer").get_children():
		if b != button:
			b.button_pressed = false
			b.get_child(0).hide()
		else:
			b.get_child(0).show()

func _on_width_slider_value_changed(value):
	get_node("WidthNum").text = str(get_node("WidthSlider").value)
	Global.cols = get_node("WidthSlider").value

func _on_height_slider_value_changed(value):
	get_node("HeightNum").text = str(get_node("HeightSlider").value)
	Global.rows = get_node("HeightSlider").value

func _on_play_button_pressed():
	play_sound(Global.click3)
	await get_node("AudioStreamPlayer2D").finished
	get_tree().change_scene_to_packed(Global.puzzle_scene)

func _ready():
	Global.rows = 4
	Global.cols = 4
	make_img_buttons()
