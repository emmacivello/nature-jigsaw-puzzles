extends Node2D

# Scenes
const puzzle_scene = preload("res://scenes/puzzle.tscn")
const customization_scene = preload("res://scenes/customize.tscn")
const howto_scene = preload("res://scenes/how_to.tscn")
const credits_scene = preload("res://scenes/credits.tscn")

# Puzzle settings (initialized and potentially customized in customize.gd)
var rows
var cols
var img
var muted = false
var io_index

# Sounds
const click1 = preload("res://sounds-clicks/click1.wav")
const click2 = preload("res://sounds-clicks/click2.wav")
const click3 = preload("res://sounds-clicks/click3.wav")

var nature_sounds = []
var imgs = []

func load_sounds():
	var sound_folder_path = "res://sounds-nature/"
	var directory = DirAccess.open(sound_folder_path)
	var files = directory.get_files()
	for f in files:
		if f.ends_with(".mp3.import") or f.ends_with(".wav.import"):
			nature_sounds.append(load(sound_folder_path+f.replace(".import", "")))

func load_images():
	var img_folder_path = "res://images-puzzles/"
	var directory = DirAccess.open(img_folder_path)
	var files = directory.get_files()
	
	for f in files:
		if f.ends_with(".png.import") or f.ends_with(".jpg.import") or f.ends_with(".JPG.import"):
			imgs.append(load(img_folder_path+f.replace(".import", "")))

func _ready():
	load_sounds()
	load_images()
