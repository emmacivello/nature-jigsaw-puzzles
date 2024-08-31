extends Node2D

#########################################
### STATE VALUES
#########################################
var dragging_state = false
var flipping_state = false
var puzzle_solved = false

#########################################
### PIECE MOVING VALUES
#########################################
var chunk_to_drag = null #clicked chunk -- aka chunk containing clicked piece
var chunk_pos_offset = Vector2(0,0) #used to prevent piece's (0,0) from jumping to mouse's (0,0)

#########################################
### PIECE SIZING VALUES
#########################################
const INIT_PIECE_SIZE = 20 # doesn't include nub size (4px)
const padding = 20 # num pixels between centered puzzle and closest screen edge
var io_collider_scale
var piece_scale
var piece_size # = INIT_PIECE_SIZE * piece_scale

#########################################
### PIECE SHAPE VALUES (UNSCALED)
#########################################
var in_collider_coord = Vector2(7.5, 0)
var out_collider_coord = Vector2(12.5, 0)

var in_coords = [
	Vector2(10,-10),
	Vector2(10,-2),
	Vector2(9,-2),
	Vector2(8,-3),
	Vector2(7,-3),
	Vector2(6,-2),
	Vector2(6,2),
	Vector2(7,3),
	Vector2(8,3),
	Vector2(9,2),
	Vector2(10,2)
]

var out_coords = [
	Vector2(10,-10),
	Vector2(10,-2),
	Vector2(11,-2),
	Vector2(12,-3),
	Vector2(13,-3),
	Vector2(14,-2),
	Vector2(14,2),
	Vector2(13,3),
	Vector2(12,3),
	Vector2(11,2),
	Vector2(10,2)
]

var flat_coords = [
	Vector2(10,-10)
]

#########################################
### VARIOUS VALUES
#########################################
@onready var audio_player = get_node("../AudioStreamPlayer2D")
var audio_queue = []
var time_elapsed = 0.0

#########################################
### PIECE NODE STRUCTURE NOTES
#########################################
# Hierarchy:
# CharacterBody2D (for move_and_slide)
# ---CollisionShape2D (group: "chunk_collider")
# ---Area2D (group: "puzzle_piece", for click detection)
# ------Polygon2D (atlas texture)
# ------Line2D (border)
# ------CollisionPolygon2D (click detection for Area2D parent)
# ------Area2D (group: "io_collider") -> 0-4 instances of this subtree per piece
# ---------CollisionShape2D





#########################################
### GENERAL PURPOSE FUNCTIONS
#########################################
func move_chunk_to_top():
	move_child(chunk_to_drag, get_child_count())

func play_audio():
	audio_player.stream = audio_queue.pop_at(0)
	audio_player.play()





#########################################
### INITIALIZATION CALCULATIONS
#########################################
func scale_coords():
	in_coords = in_coords.map(func(i): return (i * piece_scale))
	out_coords = out_coords.map(func(i): return (i * piece_scale))
	flat_coords = flat_coords.map(func(i): return (i * piece_scale))
	in_collider_coord *= piece_scale
	out_collider_coord *= piece_scale

func calculate_and_set_piece_scale():
	var viewport = get_viewport_rect()
	
	piece_size = (viewport.size.x - (2 * padding)) / Global.cols
	if (piece_size * Global.rows) + (2 * padding) > (viewport.size.y - 50):
		piece_size = ((viewport.size.y - 50) - (2 * padding)) / Global.rows
	
	piece_scale = snapped(piece_size / INIT_PIECE_SIZE, 0.1)
	piece_size = INIT_PIECE_SIZE * piece_scale
	
	io_collider_scale = piece_scale / 10





#########################################
### NODE INSTANCING FUNCTIONS
#########################################
func make_puzzle_piece(coords, io_indices, pos, r, c):
	
	# IMPORTANT: snap piece coords because coords with decimals are represented imprecisely and
	# cause problems for polygon decomposition functions (in Polygon2D and CollisionPolygon2D)
	for i in range(coords.piece_coords.size()):
		coords.piece_coords[i].x = snapped(coords.piece_coords[i].x, 1)
		coords.piece_coords[i].y = snapped(coords.piece_coords[i].y, 1)
	
	var new_char_body = MakeNodesFuncs.make_puzzle_chunk(pos)
	var new_chunk_collider = MakeNodesFuncs.make_puzzle_chunk_collider()
	var new_area = MakeNodesFuncs.make_puzzle_piece_area()
	var new_polygon = MakeNodesFuncs.make_puzzle_piece_polygon(coords.piece_coords, r, c, piece_size)
	var new_border = MakeNodesFuncs.make_puzzle_piece_border(coords.piece_coords)
	var new_collision_polygon = MakeNodesFuncs.make_puzzle_piece_collision_polygon(coords.piece_coords)
	
	add_child(new_char_body)
	new_char_body.add_child(new_chunk_collider)
	new_char_body.add_child(new_area)
	new_area.add_child(new_polygon)
	new_area.add_child(new_border)
	new_area.add_child(new_collision_polygon)
	
	for c_coords in coords.collider_coords:
		var crt_io_index = io_indices[c_coords.dir]
		new_area.add_child(MakeNodesFuncs.make_puzzle_piece_edge_collider(c_coords, crt_io_index, io_collider_scale))
	
	GeneralFuncs.resize_chunk_collider(new_char_body)

func make_puzzle():
	var piece_edge_types_and_indices = InitCalcFuncs.determine_all_edge_types_and_io_coords()
	var piece_edge_types = piece_edge_types_and_indices[0]
	var piece_edge_io_indices = piece_edge_types_and_indices[1]
	var piece_edge_and_collider_coords = InitCalcFuncs.set_piece_edge_and_collider_coords(piece_edge_types, out_coords, in_coords, flat_coords, out_collider_coord, in_collider_coord)
	
	for r in Global.rows:
		for c in Global.cols:
			# piece pos for solved, centered puzzle: 
			#var pos = Vector2(c, r) * piece_size + Vector2(piece_size/2, piece_size/2) + Vector2(get_viewport_rect().size.x/2 - piece_size*Global.cols/2, get_viewport_rect().size.y/2 - piece_size*Global.rows/2 + 25)
			var pos = InitCalcFuncs.find_random_piece_pos(piece_edge_and_collider_coords[r][c].piece_coords, get_viewport_rect().size)
			make_puzzle_piece(piece_edge_and_collider_coords[r][c], piece_edge_io_indices[r][c], pos, r, c)





#########################################
### INPUT PROCESSING FUNCTIONS
#########################################
func find_clicked_areas():
	var physics_point_query_params = PhysicsPointQueryParameters2D.new()
	physics_point_query_params.position = get_viewport().get_mouse_position()
	physics_point_query_params.collide_with_areas = true # find pieces
	physics_point_query_params.collide_with_bodies = false # ignore chunks
	var areas = get_world_2d().get_direct_space_state().intersect_point(physics_point_query_params)
	
	var puzzle_pieces = []
	for a in areas:
		if a.collider.is_in_group("puzzle_piece"):
			puzzle_pieces.append(a)
	
	return puzzle_pieces

func find_top_piece(piece_area_arr):
	if piece_area_arr.size() > 0:
		var largest_index = piece_area_arr[0].collider.get_parent().get_index()
		var top_piece = piece_area_arr[0].collider
		
		for piece in piece_area_arr.slice(1):
			var piece_index = piece.collider.get_parent().get_index()
			if piece_index > largest_index:
				largest_index = piece_index
				top_piece = piece.collider
		
		return top_piece
	else:
		return null

func find_clicked_chunk():
	# chunk collider is rectangle-shaped, so can't just look for mouse collision with it;
	# would result in a click on blank space registering as a click on a chunk;
	# instead, look for clicks on the child pieces (whose collision shapes are fitted
	# to the graphics) and then get their parent chunk
	var top_piece = find_top_piece(find_clicked_areas())
	if top_piece != null:
		return top_piece.get_parent()
	return null





#########################################
### GAME STATES
#########################################
func start_move_chunk_state():
	dragging_state = true
	move_chunk_to_top()
	chunk_to_drag.get_child(0).disabled = false
	chunk_pos_offset = get_global_mouse_position() - chunk_to_drag.position

func end_move_chunk_state():
	dragging_state = false
	chunk_to_drag.get_child(0).disabled = true
	var connection_found = ConnectPiecesFuncs.find_and_make_chunk_connections(chunk_to_drag)
	if connection_found and !Global.muted:
		var new_sound = Global.nature_sounds[randi_range(0,Global.nature_sounds.size()-1)]
		audio_queue = [Global.click1, new_sound]
		play_audio()
	if GeneralFuncs.check_puzzle_solved() and !puzzle_solved:
		puzzle_finished_state()

func puzzle_finished_state():
	puzzle_solved = true
	
	for a in get_tree().get_nodes_in_group("puzzle_piece"):
		var tween = get_tree().create_tween()
		tween.tween_property(a.get_child(1), "modulate:a", 0.0, 0.5)
	
	get_node("../TopMenu/SuccessMessage").visible = true
	
	var extra_message = ""
	if time_elapsed < 60:
		extra_message = "     Solved in less than 1 min"
	elif time_elapsed < 300:
		extra_message = "     Solved in less than 5 min"
	elif time_elapsed < 600:
		extra_message = "     Solved in less than 10 min"
	get_node("../TopMenu/SuccessMessage").text += extra_message





#########################################
### PROCESSING FUNCTIONS
#########################################
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed(): # mouse down event
			chunk_to_drag = find_clicked_chunk()
			if chunk_to_drag != null:
				start_move_chunk_state()
		elif dragging_state: # (and is a mouse up event)
			end_move_chunk_state()

func _physics_process(_delta):
	if dragging_state:
		chunk_to_drag.velocity = (get_global_mouse_position() - chunk_to_drag.position - chunk_pos_offset) * 50
		chunk_to_drag.move_and_slide()

func _process(delta):
	if !Global.muted and audio_queue.size() > 0 and !audio_player.playing:
		play_audio()
	elif Global.muted:
		audio_player.playing = false
		audio_queue = []
	
	if !puzzle_solved:
		time_elapsed += delta
		get_node("../TopMenu/Time").text = GeneralFuncs.format_time_str(int(floor(time_elapsed)))

func _ready():
	Global.io_index = 0
	
	calculate_and_set_piece_scale()
	scale_coords()
	make_puzzle()
