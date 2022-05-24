extends Node2D


#var bonusE = preload("res://arena/BonusE.tscn")
#var bonusM = preload("res://arena/BonusM.tscn")

#levels
const LVL_PATH = "res://arena/levels/Level0%d.tscn"	#kličemo level s številko kot spremenlijvko %d

const ROOM_PATH = "res://arena/rooms/Room_%s.tscn"	#kličemo level s številko kot spremenlijvko %d

var selected_room_name: String = "Test"


var lvl_num : int = 1

onready var timer #:= $UniversalTajm	# We cache the children should we need to access them again
onready var timer_target := self


# -------------------------------------------------------------------------------------------------------------------


func _ready() -> void:

	Global.node_creation_parent = self

	# SETUP
	$Room/Background/Zvezde.emitting = true
#	$Enviroment/Magnet/part_Blackhole.emitting = true

	#level load
	call_deferred("init")	# defferd je zato, da se v miru vse nasloži potem pa se zažene


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		Global.game_manager.toggle_pause()
	elif Input.is_action_just_released("ui_accept"):
		Global.game_manager.toggle_pause_alt()


func _process(delta: float) -> void:

#	if Input.is_key_pressed(KEY_ESCAPE):
#	if Input.is_action_just_pressed("ui_cancel"):
#		$ConfigurePlayerMenu.open()
#		get_tree().change_scene("res://hud/input_menu/InputMenu.tscn")
	pass


func _exit_tree() -> void:
	Global.node_creation_parent = null		# tu arena na obstaja več, zato tudi starš ne obstaja več ali se zamenja

func init():
#	load_level(lvl_num)

#	selected_room_name =
	load_room ()
	
	pass
func load_room ():

#	if Global.node_creation_parent.has_node("Room"): # če je node z imenom "že prisoten, potem removamo trenuten level in damo notri novega po zaporedni številki
#		Global.node_creation_parent.remove_child ($Room)	

	# todo: check if level actually exists
	var new_selected_room = load(ROOM_PATH % selected_room_name).instance()
#	selected_room.modulate = Color.darkgray
	var room = Global.node_creation_parent.get_node("Room")
	room.add_child(new_selected_room)

	return true

func load_level (num : int):

	var root = Global.node_creation_parent
	if root.has_node("TestLevel"):
		root.remove_child ($TestLevel)	# če je node z imenom "že prisoten, potem removamo trenuten level in dsmo notri novega po zaporedni številki

	# todo: check if level actually exists
	var lvl = load(LVL_PATH % num).instance()
	lvl.modulate = Color.darkgray
	root.add_child(lvl)

	return true

func _target_connected():	# INLINE TIMER
	print ("target connected")
	pass
