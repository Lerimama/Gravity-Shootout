extends KinematicBody2D


var misile_color : Color # player color iz slovarja

var speed = GameProfiles.weapon_values["misile_speed"]
var velocity = Vector2(1, 0)

#var check_once = true

# --------------------------------------------------------------------------------------------------

func _ready() -> void:

	modulate = misile_color

#	add_to_group("misiles")
#	add_to_group("weapons")


func _physics_process(delta: float) -> void:
	global_position += velocity.rotated(rotation) * speed * delta # rotation je v radiantih, ki jih rotated funkcija rabi (rotation_degrees je v stopinjah)

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()

func pause_me():
	set_physics_process(false)


func unpause_me():
	set_physics_process(true)

