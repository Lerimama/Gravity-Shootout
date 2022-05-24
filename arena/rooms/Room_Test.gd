extends Node2D


# tale je po Room_00 inheritana scena 

# FX brick_tile_index
const MAGNET := 1 
const BOUNCER := 2
const POINTER := 3
const EXPLODER := 4

export (PackedScene) var magnet
export (PackedScene) var bouncer
export (PackedScene) var pointer
export (PackedScene) var exploder

func _ready() -> void:
	call_deferred("setup_tiles")	# funkcijo "setup_tiles" se izvede šele, ko se celotn drevo naloži

func setup_tiles():
	
	# dobi index vseh tiletov ... će  ima -1 ni uporabljen
	var tile_map = $BrickSet.get_used_cells()

	for tile in tile_map:
		
		var tile_index = $BrickSet.get_cell(tile.x, tile.y)
			
		match tile_index: # dodamo v isto drevo kot je trnutni Brickset
			MAGNET: create_instance_from_tilemap (tile, magnet, self, Vector2 (16,16))	
			BOUNCER: create_instance_from_tilemap (tile, bouncer, self, Vector2 (16,16))
			POINTER: create_instance_from_tilemap (tile, pointer, self, Vector2 (16,16))
			EXPLODER: create_instance_from_tilemap (tile, exploder, self, Vector2 (16,16))


func create_instance_from_tilemap(coord:Vector2, brick_scene:PackedScene, parent: Node2D, brick_anchor_offset:Vector2): # = Vector2.ZERO):	# primer dobre prakse ... static typing
	
	$BrickSet.set_cell(coord.x, coord.y, -1 )	# zbrišeš trenutni tile tako da ga zamenjaš z indexom -1 (prazen tile)
	var new_brick_scene = brick_scene.instance() #
	new_brick_scene.position = $BrickSet.map_to_world(coord) + brick_anchor_offset
	parent.add_child(new_brick_scene)	


func pause_me():

	# vsak element v levelu dobi svojo pavzo
	for child in get_children():
		if child.has_method("pause_me"):
			print("PAUSED CHILD")
			print(child)
			child.pause_me()


func unpause_me():

	# vsak element v levelu dobi svojo pavzo
	for child in get_children():
		if child.has_method("unpause_me"):
			print("CHILD ACTIVE AGAIN")
			print(child)
			child.unpause_me()
