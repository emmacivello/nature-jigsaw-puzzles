# autoloaded as MakeNodesFuncs
extends Node

func make_puzzle_chunk(pos):
	var new_char_body = CharacterBody2D.new()
	new_char_body.position = pos
	new_char_body.set_collision_mask_value(1, false)
	new_char_body.set_collision_mask_value(2, true) # only collides w border on layer 2, not other pieces
	return new_char_body

func make_puzzle_chunk_collider():
	var new_collider = CollisionShape2D.new()
	new_collider.shape = RectangleShape2D.new()
	new_collider.add_to_group("chunk_collider")
	new_collider.disabled = true
	return new_collider

func make_puzzle_piece_area():
	var new_area = Area2D.new()
	new_area.set_collision_mask_value(1,false) # so these aren't detecting each other
	new_area.add_to_group("puzzle_piece")
	return new_area

func make_puzzle_piece_polygon(edge_coords, r, c, piece_size):
	var new_polygon = Polygon2D.new()
	new_polygon.polygon = PackedVector2Array(edge_coords)
	
	var new_atlas_text = AtlasTexture.new()
	new_atlas_text.atlas = Global.img
	
	var puzzle_width = Global.cols * piece_size
	var puzzle_height = Global.rows * piece_size
	
	var img_width = Global.img.get_width()
	var img_height = Global.img.get_height()
	
	# snap region/image size to longer dimension of puzzle (so we get overflow, not shadowbox)
	var reg_width
	var reg_height
	if puzzle_height < puzzle_width:
		reg_width = puzzle_width
		reg_height = (img_height * reg_width) / img_width
		
		if reg_height < puzzle_height:
			reg_height = puzzle_height
			reg_width = (reg_height * img_width) / img_height
	else:
		reg_height = puzzle_height
		reg_width = (reg_height * img_width) / img_height
		
		if reg_width < puzzle_width:
			reg_width = puzzle_width
			reg_height = (img_height * reg_width) / img_width
	
	# to make image center line up with puzzle center, even if they're different dimensions:
	var img_center_offset = Vector2(reg_width/2 - puzzle_width/2, reg_height/2 - puzzle_height/2)
	
	new_atlas_text.region = Rect2(0, 0, reg_width, reg_height)
	
	new_polygon.texture = new_atlas_text
	new_polygon.texture_offset = Vector2(c * piece_size + piece_size/2 + img_center_offset.x, r * piece_size + piece_size/2 + img_center_offset.y)
	
	return new_polygon

func make_puzzle_piece_collision_polygon(edge_coords):
	var new_collision_polygon = CollisionPolygon2D.new()
	new_collision_polygon.polygon = PackedVector2Array(edge_coords)
	return new_collision_polygon

func make_puzzle_piece_edge_collider(collider_coords, crt_io_index, io_collider_scale):
	var new_collider_area = Area2D.new()
	new_collider_area.position = collider_coords.coord
	new_collider_area.add_to_group("io_collider")
	
	new_collider_area.set_meta("io_index",crt_io_index)
	
	# move to new mask, layer to minimize collision pairs
	new_collider_area.set_collision_mask_value(1,false)
	new_collider_area.set_collision_layer_value(1,false)
	new_collider_area.set_collision_mask_value(3,true)
	new_collider_area.set_collision_layer_value(3,true)
	
	var new_collider = CollisionShape2D.new()
	new_collider.shape = CircleShape2D.new()
	new_collider.scale = Vector2(io_collider_scale, io_collider_scale)
	
	new_collider_area.add_child(new_collider)
	
	return new_collider_area

func make_puzzle_piece_border(edge_coords):
	var new_line = Line2D.new()
	new_line.default_color = Color(0.5,0.5,0.5)
	new_line.width = 1
	for ec in edge_coords:
		new_line.add_point(ec)
	new_line.add_point(edge_coords[0])
	return new_line
