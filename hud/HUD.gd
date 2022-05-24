extends Node2D


var playerStats = preload("res://hud/PlayerStats.tscn")
var spawned_player_profile
var playerstats_index: int = 0 # index znotraj ene runde
var playerstats_round: int = 0 # ena runda so 4 hudi

var odmik_od_roba = 24
var odmik_od_roba_spodaj = 48 # adaptacija za anchor
var playerstats_w = 350
var playerstats_h = 38
var premik_runde = 38


func _ready() -> void:
	
	Global.game_manager.connect("Player_spawned", self, "on_Player_spawned") # signal pride iz GM in pošlje profil spawnanega igralca
	Global.game_manager.connect("Player_HUD_change", self, "on_Player_HUD_change") # signal pride iz GM in pošlje spremenjeno statistiko
	Global.game_manager.connect("Player_spawned_Q", self, "on_Player_spawned_Q") # signal pride iz GM in pošlje spremenjeno statistiko
	
func on_Player_spawned_Q(spawned_player_profile: Dictionary, spawned_player_stats: Dictionary, player_index: int ): # samo za hitri spawn
	
	print("HEY")
	var player_name = spawned_player_profile["player_name"]
	var player_game_stats = spawned_player_stats
	
	# generiraj playerstats
	var new_playerstats = playerStats.instance()
	new_playerstats.set_name("p%s_playerstats" % player_index) # potrebno za kasnejše iskanje nodeta v drevesu
	
	# izračun playerstats pozicije
	playerstats_index = player_index # index višamo do 4, potem se resetira ... def je 0
	match playerstats_index:
		1: 
			new_playerstats.set_position(Vector2( 0 + odmik_od_roba, 0 + odmik_od_roba  + premik_runde * playerstats_round ))
		2: 
#			playerstats_round += 1
#			new_playerstats.set_position(Vector2( 0 + odmik_od_roba, 0 + odmik_od_roba  + premik_runde * playerstats_round ))
			new_playerstats.set_position(Vector2( get_viewport().size.x - playerstats_w - odmik_od_roba , 0 + odmik_od_roba + premik_runde * playerstats_round ))
		3: 
			new_playerstats.set_position(Vector2( 0 + odmik_od_roba, get_viewport().size.y - odmik_od_roba_spodaj - premik_runde  * playerstats_round ))
		4: 
			new_playerstats.set_position(Vector2( get_viewport().size.x - playerstats_w - odmik_od_roba , get_viewport().size.y - odmik_od_roba_spodaj - premik_runde * playerstats_round ))
			playerstats_index	= 0 # začne se nova runda ... resetiramo plejerstats index
			playerstats_round += 1 # začne se nova runda
			
	# per-player
	new_playerstats.get_node("PlayerName").text = player_name
	new_playerstats.get_node("Avatar").texture = spawned_player_profile["player_avatar"]
	for stat_label in new_playerstats.get_children(): # barva
		stat_label.modulate = spawned_player_profile["player_color"]
	
	# game stats
#	new_playerstats.get_node("EnergyProgressBar").def_energy = spawned_player_profile["energy"]
	new_playerstats.get_node("EnergyProgressBar/Label").text = str(player_game_stats["energy"])
	new_playerstats.get_node("LifeCounter/Label").text = str(player_game_stats["life"]) # zakaj more bit tukej string?
	new_playerstats.get_node("ScoreCounter/Label").text = "%04d" % player_game_stats["score"]
	new_playerstats.get_node("BulletCounter/Label").text = "%02d" % player_game_stats["bullet_no"]
	new_playerstats.get_node("MisileCounter/Label").text = "%02d" % player_game_stats["misile_no"]

	# skrijemo gejmover in win
	new_playerstats.get_node("GameoverLabel").hide()
	new_playerstats.get_node("WinLabel").hide()

	Global.node_creation_parent.get_node("HUD").add_child(new_playerstats)


func on_Player_spawned(spawned_player_profile: Dictionary, spawned_player_index: int): # kreacija huda za plejerja
	# ta funkcija se izvrši za vsakega plejerja posebej

	var player_name = spawned_player_profile["player_name"]
	var player_game_stats = spawned_player_profile["player_game_stats"]
	
	# generiraj playerstats
	var new_playerstats = playerStats.instance()
	new_playerstats.set_name("p%s_playerstats" % spawned_player_index) # potrebno za kasnejše iskanje nodeta v drevesu
	
	# izračun playerstats pozicije
	playerstats_index += 1 # index višamo do 4, potem se resetira ... def je 0
	match playerstats_index:
		1: 
			new_playerstats.set_position(Vector2( 0 + odmik_od_roba, 0 + odmik_od_roba  + premik_runde * playerstats_round ))
		2: 
			new_playerstats.set_position(Vector2( get_viewport().size.x - playerstats_w - odmik_od_roba , 0 + odmik_od_roba + premik_runde * playerstats_round ))
		3: 
			new_playerstats.set_position(Vector2( 0 + odmik_od_roba, get_viewport().size.y - odmik_od_roba_spodaj - premik_runde  * playerstats_round ))
		4: 
			new_playerstats.set_position(Vector2( get_viewport().size.x - playerstats_w - odmik_od_roba , get_viewport().size.y - odmik_od_roba_spodaj - premik_runde * playerstats_round ))
			playerstats_index	= 0 # začne se nova runda ... resetiramo plejerstats index
			playerstats_round += 1 # začne se nova runda
			
	# per-player
	new_playerstats.get_node("PlayerName").text = player_name
	new_playerstats.get_node("Avatar").texture = spawned_player_profile["player_avatar"]
	for stat_label in new_playerstats.get_children(): # barva
		stat_label.modulate = spawned_player_profile["player_color"]
	
	# game stats
#	new_playerstats.get_node("EnergyProgressBar").def_energy = spawned_player_profile["energy"]
	new_playerstats.get_node("EnergyProgressBar/Label").text = str(player_game_stats["energy"])
	new_playerstats.get_node("LifeCounter/Label").text = str(player_game_stats["life"]) # zakaj more bit tukej string?
	new_playerstats.get_node("ScoreCounter/Label").text = "%04d" % player_game_stats["score"]
	new_playerstats.get_node("BulletCounter/Label").text = "%02d" % player_game_stats["bullet_no"]
	new_playerstats.get_node("MisileCounter/Label").text = "%02d" % player_game_stats["misile_no"]

	# skrijemo gejmover in win
	new_playerstats.get_node("GameoverLabel").hide()
	new_playerstats.get_node("WinLabel").hide()

	Global.node_creation_parent.get_node("HUD").add_child(new_playerstats)
	

func on_Player_HUD_change(player_index, stat_name, new_stat_value):
#	(player_index, changed_stat_name, changed_stat_new_value):

	print ("POVEZANO")
	print (player_index)
	print (stat_name)
	print (new_stat_value)

	# določimo playerstats
	var stats_of_player = Global.node_creation_parent.get_node("HUD/p%s_playerstats" % player_index)
	
	# če se je zgodila izguba lajfa na 0 ...
	if stat_name == "life" && new_stat_value <= 0:
		# skrijemo gejmover in win
		stats_of_player.get_node("ScoreCounter").hide()
		stats_of_player.get_node("EnergyProgressBar").hide()
		stats_of_player.get_node("LifeCounter").hide()
		stats_of_player.get_node("BulletCounter").hide()
		stats_of_player.get_node("MisileCounter").hide()
		
		# GAME OVER
		stats_of_player.get_node("GameoverLabel").show()
#		new_playerstats.get_node("WinLabel").hide()
			
	else:	  
		match stat_name:
			"score" : stats_of_player.get_node("ScoreCounter/Label").text = "%04d" % new_stat_value
			"energy" :
				stats_of_player.get_node("EnergyProgressBar").def_energy = new_stat_value
				stats_of_player.get_node("EnergyProgressBar/Label").text = str(new_stat_value)
			"life" :
				stats_of_player.get_node("LifeCounter/Label").text = str(new_stat_value)
			"bullet_no" : stats_of_player.get_node("BulletCounter/Label").text = "%02d" % new_stat_value
			"misile_no" : stats_of_player.get_node("MisileCounter/Label").text = "%02d" % new_stat_value
