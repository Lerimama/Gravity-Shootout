extends KinematicBody2D


var bullet_color : Color # player color iz slovarja

var speed = GameProfiles.weapon_values["bullet_speed"]
var velocity = Vector2(1, 0)

#var check_once = true
#var bullet_owner = 0



# --------------------------------------------------------------------------------------------------

func _ready() -> void:

	modulate = bullet_color

#	add_to_group("bullets")
#	add_to_group("weapons")

func _physics_process(delta: float) -> void:
	global_position += velocity.rotated(rotation) * speed * delta # rotation je v radiantih, ki jih rotated funkcija rabi (rotation_degrees je v stopinjah)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_ForceField_body_entered(body: Node) -> void:
#	queue_free()
	set_deferred("queue_free", true) # ne vem če pomaga
	pass # Replace with function body.

func hit_reaction(): # preverjamo če ma metodo?
	print ("BULLET HIT BY ...")
	pass

func pause_me():
	set_physics_process(false)


func unpause_me():
	set_physics_process(true)

