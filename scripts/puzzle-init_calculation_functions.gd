# autoloaded as InitCalcFuncs
extends Node

func determine_piece_io_indices(piece_io_indices, piece_row, piece_col):
	var edge_io_indices = {"n":null, "e":null, "s":null, "w":null}
	
	# set n
	if piece_row != 0:
		edge_io_indices.n = piece_io_indices[piece_row-1][piece_col].s
	# set e
	if piece_col != Global.cols-1:
		edge_io_indices.e = Global.io_index
		Global.io_index += 1
	# set s
	if piece_row != Global.rows-1:
		edge_io_indices.s = Global.io_index
		Global.io_index += 1
	# set w
	if piece_col != 0:
		edge_io_indices.w = piece_io_indices[piece_row][piece_col-1].e
	
	return edge_io_indices

func determine_piece_edge_types(prev_piece_coords, piece_row, piece_col):
	# should be called so that all rows above and cols to left of crt
	# piece have already been set and are in variable board
	var edge_types = {"n":null, "e":null, "s":null, "w":null}
	
	# set n
	if piece_row != 0:
		edge_types.n = !prev_piece_coords[piece_row-1][piece_col].s
	# set e
	if piece_col != Global.cols-1:
		edge_types.e = GeneralFuncs.rand_bool()
	# set s
	if piece_row != Global.rows-1:
		edge_types.s = GeneralFuncs.rand_bool()
	# set w
	if piece_col != 0:
		edge_types.w = !prev_piece_coords[piece_row][piece_col-1].e
	
	return edge_types

func determine_all_edge_types_and_io_coords():
	# types are: flat, in/false, out/true
	var piece_edge_types = []
	var piece_io_indices = []
	
	for r in range(Global.rows):
		piece_edge_types.append([])
		piece_io_indices.append([])
		for c in range(Global.cols):
			piece_edge_types[r].append(determine_piece_edge_types(piece_edge_types, r, c))
			piece_io_indices[r].append(determine_piece_io_indices(piece_io_indices, r, c))
	
	return [piece_edge_types, piece_io_indices]

func set_and_rotate_edge_coords(edge_position, edge_type, out_coords, in_coords, flat_coords):
	# works for one edge at a time
	var shape_coords = [] # for the piece's outline (used for Polygon2D and CollisionPolygon2D)
	
	match edge_type:
		true:
			shape_coords = out_coords.duplicate()
		false:
			shape_coords = in_coords.duplicate()
		null:
			shape_coords = flat_coords.duplicate()
	
	# coords auto face east; so, change if edge_position != "e"
	match edge_position:
		"n":
			shape_coords = GeneralFuncs.rotate_pts(shape_coords, 3*PI/2)
		"s":
			shape_coords = GeneralFuncs.rotate_pts(shape_coords, PI/2)
		"w":
			shape_coords = GeneralFuncs.rotate_pts(shape_coords, PI)
	
	return shape_coords

func set_and_rotate_io_collider_coord(edge_position, edge_type, out_collider_coord, in_collider_coord):
	var edge_collider_coord = null
	match edge_type:
		true:
			edge_collider_coord = out_collider_coord
		false:
			edge_collider_coord = in_collider_coord
	
	if edge_collider_coord != null:
		match edge_position:
			"n":
				edge_collider_coord = GeneralFuncs.rotate_pt(edge_collider_coord, 3*PI/2)
			"s":
				edge_collider_coord = GeneralFuncs.rotate_pt(edge_collider_coord, PI/2)
			"w":
				edge_collider_coord = GeneralFuncs.rotate_pt(edge_collider_coord, PI)
		edge_collider_coord = {"coord":edge_collider_coord, "dir":edge_position}
	
	return edge_collider_coord

func set_piece_edge_and_collider_coords(piece_edge_types, out_coords, in_coords, flat_coords, out_collider_coord, in_collider_coord):
	var piece_edge_and_collider_coords = []
	for r in range(Global.rows):
		piece_edge_and_collider_coords.append([])
		for c in range(Global.cols):
			var crt_coords = []
			crt_coords.append_array(set_and_rotate_edge_coords("n", piece_edge_types[r][c].n, out_coords, in_coords, flat_coords))
			crt_coords.append_array(set_and_rotate_edge_coords("e", piece_edge_types[r][c].e, out_coords, in_coords, flat_coords))
			crt_coords.append_array(set_and_rotate_edge_coords("s", piece_edge_types[r][c].s, out_coords, in_coords, flat_coords))
			crt_coords.append_array(set_and_rotate_edge_coords("w", piece_edge_types[r][c].w, out_coords, in_coords, flat_coords))
			
			var crt_collision_coords = []
			crt_collision_coords.append(set_and_rotate_io_collider_coord("n", piece_edge_types[r][c].n, out_collider_coord, in_collider_coord))
			crt_collision_coords.append(set_and_rotate_io_collider_coord("e", piece_edge_types[r][c].e, out_collider_coord, in_collider_coord))
			crt_collision_coords.append(set_and_rotate_io_collider_coord("s", piece_edge_types[r][c].s, out_collider_coord, in_collider_coord))
			crt_collision_coords.append(set_and_rotate_io_collider_coord("w", piece_edge_types[r][c].w, out_collider_coord, in_collider_coord))
			crt_collision_coords = GeneralFuncs.strip_nulls(crt_collision_coords)
			
			piece_edge_and_collider_coords[r].append({"piece_coords":crt_coords, "collider_coords":crt_collision_coords})
	
	return piece_edge_and_collider_coords

func find_random_piece_pos(piece_coords, viewport_size):
	var piece_dims = GeneralFuncs.find_width_height(piece_coords)
	var x_pos = randi_range(0 - piece_dims.min_x, viewport_size.x - (piece_dims.min_x + piece_dims.w))
	var y_pos = 50 + randi_range(0 - piece_dims.min_y, viewport_size.y - (piece_dims.min_y + piece_dims.h) - 50)
	return Vector2(x_pos, y_pos)
