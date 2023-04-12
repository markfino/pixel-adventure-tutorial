extends Enemy

@export var walk_speed:float = 75
@export var run_speed: float = 150



enum STATE {
	WALK,
	RUN,
	HIT
}

func _init():
	collision_damage = 1

var current_state: STATE = STATE.WALK

func _physics_process(delta):
	waypoint_move(delta)

func _get_move_velocity(delta, direction):
	var direction_x_sign = sign(direction.x)
		
	var move_speed: float
	match(current_state):
		STATE.WALK:
			move_speed = walk_speed
		STATE.RUN:
			move_speed = run_speed
	
	velocity = Vector2(
		move_speed * direction_x_sign,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)

func _on_angry_detection_zone_body_entered(body):
	animation_tree.set("parameters/player_detected/blend_position", 1)
	if (self.current_state == STATE.WALK):
		self.current_state = STATE.RUN

func _on_angry_detection_zone_body_exited(body):
	animation_tree.set("parameters/player_detected/blend_position", 0)
	if (self.current_state == STATE.RUN):
		self.current_state = STATE.WALK

func _hit_animation_finished():
	can_be_hit = true
	current_state = STATE.RUN
	
func get_hit(damage: float):
	health -= damage
	
	can_be_hit = false
	current_state = STATE.HIT
	
#	print("pig got hit")
	
	var rng = GameSettings.RandomGen
	var anim_selection = rng.randi_range(0, 1)
	
	animation_tree.set("parameters/hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/hit_variation/blend_amount", anim_selection)
