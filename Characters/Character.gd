class_name Character extends CharacterBody2D

@export var health: float = 3:
	get:
		return health
	set(value):
		health = value
		if (health == 0):
			queue_free()

func _get_hit(damage: float):
	push_error("Get hit has not been implemented")
	
func _on_hit_finished():
	push_error("On hit finished has not been implemented")

	
