# autoloaded as ConnectPiecesFuncs
extends Node

func find_and_make_chunk_connections(chunk):
	# for each individual piece (Area2D) within the chunk
	var connection_found = false
	for puzzle_piece_area in chunk.get_children().slice(1):
		if is_instance_valid(puzzle_piece_area):
			
			for edge_collider in puzzle_piece_area.get_children().slice(3):
				
				if is_instance_valid(edge_collider):
					var ec_io_index = edge_collider.get_meta("io_index")
					
					# for each collider (belonging to other pieces) that touches the current collider
					for neighboring_edge_collider in edge_collider.get_overlapping_areas():
						
						if neighboring_edge_collider.is_in_group("io_collider"):
							var nec_io_index = neighboring_edge_collider.get_meta("io_index")
							
							# if the colliding colliders represent pieces that should be joined, join them
							if ec_io_index == nec_io_index:
								connection_found = true
								connect_chunks(edge_collider, neighboring_edge_collider)
								break
	if connection_found:
		return true
	return false

func remove_used_io_colliders(c1, c2):
	var c1_colliders = []
	var c2_colliders = []
	for puzzle_piece_area in c1.get_children():
		c1_colliders.append_array(puzzle_piece_area.get_children().slice(3))
	for puzzle_piece_area in c2.get_children():
		c2_colliders.append_array(puzzle_piece_area.get_children().slice(3))
	
	var nodes_to_free = []
	
	for c1_collider in c1_colliders:
		for c2_collider in c2_colliders:
			if c1_collider.get_overlapping_areas().has(c2_collider) or c2_collider.get_overlapping_areas().has(c1_collider):
				if !nodes_to_free.has(c1_collider):
					nodes_to_free.append(c1_collider)
				if !nodes_to_free.has(c2_collider):
					nodes_to_free.append(c2_collider)
	
	for n in nodes_to_free:
		n.free()

func reparent_chunk(c1, c2, offset):
	# moves pieces in chunk2 to c1 and removes c2
	c2.get_children().slice(1).map(func(i):
		i.reparent(c1, false)
		i.position += offset)
	c2.free()

func connect_chunks(io_collider1, io_collider2):
	var piece1 = io_collider1.get_parent()
	var piece2 = io_collider2.get_parent()
	var chunk1 = piece1.get_parent()
	var chunk2 = piece2.get_parent()
	
	var chunk2_offset = (piece1.position + io_collider1.position) - (piece2.position + io_collider2.position)
	
	remove_used_io_colliders(chunk1, chunk2)
	reparent_chunk(chunk1, chunk2, chunk2_offset)
	GeneralFuncs.resize_chunk_collider(chunk1)
