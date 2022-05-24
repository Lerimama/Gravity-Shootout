extends Node2D

const MAGNET := 1 # magnet tile index
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
	var cells = $BrickSet.get_used_cells()	# dobi index vseh tiletov ... će  ima - 1 ni uporabljen

	for cell in cells:
		var index = $BrickSet.get_cell(cell.x, cell.y)
		match index:
			MAGNET:
				create_instance_from_tilemap (cell, magnet, self, Vector2 (20,19))	# dodamo v isto drevo kot je trnutni Brickset
				print ("magnet dodan")
			BOUNCER:
				create_instance_from_tilemap (cell, bouncer, self, Vector2 (20,19))	# dodamo v isto drevo kot je trnutni Brickset
				print ("bouncer dodan")
			POINTER:
				create_instance_from_tilemap (cell, pointer, self, Vector2 (20,19))	# dodamo v isto drevo kot je trnutni Brickset
				print ("pointer dodan")
			EXPLODER:
				create_instance_from_tilemap (cell, exploder, self, Vector2 (20,19))	# dodamo v isto drevo kot je trnutni Brickset
				print ("exploder dodan")


func create_instance_from_tilemap(coord:Vector2, prefab:PackedScene, parent: Node2D, origin_zamik:Vector2 = Vector2.ZERO):	# primer dobre prakse ... static typing
	$BrickSet.set_cell(coord.x, coord.y, -1 )	# zbrišeš trenutni tile tako da ga zamenjaš z indexom -1 (prazen tile)
	var pf = prefab.instance()
	pf.position = $BrickSet.map_to_world(coord) - origin_zamik
	parent.add_child(pf)

#	var local_position = my_tilemap.map_to_world(map_position)
#	var global_position = my_tilemap.to_global(local_position)

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
