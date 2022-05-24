extends Area2D


var mina_color : Color # player color iz slovarja

func _ready() -> void:

	modulate = mina_color

#	add_to_group("mine")
#	add_to_group("weapons")



#func _on_ForceField_body_entered(body: Node) -> void:
#
#	if body.is_in_group ("players"):
#
#		body.velocity /= pointer_brake
#		$AnimationPlayer.play("outro")
##		$CollisionShape2D.set_deferred("disabled", true)
#		$PointerForceField/CollisionShape2D.set_deferred("disabled", true)
#		modulate = body.player_color
#
#func _on_ForceField_body_exited(body: Node) -> void:
#	pass # Replace with function body.
#

func _on_Mina_body_entered(body: Node) -> void:

	if body.is_in_group ("players"):
#		body.velocity /= pointer_brake
#		$AnimationPlayer.play("outro")
#		$CollisionShape2D.set_deferred("disabled", true)
		modulate = body.player_color
		set_deferred("disabled", true)
		print("BUUUUUUM!!!!")


func pause_me():
#	set_physics_process(false)
	pass


func unpause_me():
#	set_physics_process(true)
	pass
