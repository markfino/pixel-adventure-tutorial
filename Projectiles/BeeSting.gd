extends CharacterBody2D

@export var damage: float = 1
@export var move_speed: float = 100

var target_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	
	var collision = move_and_collide(move_speed * target_direction * delta)
	
	if (is_instance_valid(collision)):
		queue_free()
		
func _on_attack_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	body.get_hit(damage)
	queue_free()
