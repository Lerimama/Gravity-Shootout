extends StaticBody2D

var pointer_score = 100
var pointer_color = Color.aquamarine
var pointer_brake = 3

var def_particle_speed = 6

func _ready() -> void:

#	name = "Pointer"
#	add_to_group("pointers")

	modulate = pointer_color


func _on_ForceField_body_entered(body: Node) -> void:

	if body.is_in_group ("players"):

		body.velocity /= pointer_brake
		$AnimationPlayer.play("outro")
#		$CollisionShape2D.set_deferred("disabled", true)
		$PointerForceField/CollisionShape2D.set_deferred("disabled", true)
		modulate = body.player_color

func _on_ForceField_body_exited(body: Node) -> void:
	pass # Replace with function body.

func pause_me():
	$part_Points.speed_scale = 0
	$AnimationPlayer.stop(false)

func unpause_me():
	$part_Points.speed_scale = def_particle_speed
	$AnimationPlayer.play()
