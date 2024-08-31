# autoloaded as GeneralFuncs
extends Node

func rand_bool():
	return [false, true][randi() % 2]

func rotate_pt(pt, angle):
	var old_x = pt.x
	pt.x = (pt.x * cos(angle)) - (pt.y * sin(angle))
	pt.y = (old_x * sin(angle)) + (pt.y * cos(angle))
	return pt

func rotate_pts(pts, angle):
	return pts.map(func(i): return rotate_pt(i, angle))

func find_width_height(coords):
	var min_x = 0
	var max_x = 0
	var min_y = 0
	var max_y = 0
	for c in coords:
		min_x = min(c.x, min_x)
		max_x = max(c.x, max_x)
		min_y = min(c.y, min_y)
		max_y = max(c.y, max_y)
	return {"w":(max_x - min_x), "h":(max_y - min_y), "min_x":min_x, "min_y":min_y}

func find_chunk_size(chunk):
	var coords = []
	
	for puzzle_piece in chunk.get_children().slice(1): # start from 1st child of chunk because 0th is the collider
		var polygon_coords = Array(puzzle_piece.get_child(0).polygon) # first child of each piece is polygon
		polygon_coords = polygon_coords.map(func(i): return i+puzzle_piece.position) #piece coords adjusted for piece pos in chunk
		coords.append_array(polygon_coords)
	
	return find_width_height(coords)

func strip_nulls(arr):
	while arr.has(null):
		arr.erase(null)
	return arr

func check_puzzle_solved():
	return get_tree().get_nodes_in_group("chunk_collider").size() == 1

func resize_chunk_collider(chunk):
	var collider = chunk.get_child(0)
	var size = find_chunk_size(chunk)
	collider.shape.extents = Vector2(size.w/2, size.h/2)
	collider.position = Vector2(size.min_x + size.w/2, size.min_y + size.h/2)

func format_time_str(time_in_secs):
	#timer code: https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174/2
	var seconds = time_in_secs % 60
	var minutes = (time_in_secs / 60) % 60
	var hours = (time_in_secs / 60) / 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
