extends Enemy

enum STATE { IDLE, HIT, ATTACK }

@export var fly_speed: float = 50
@export var projectile: PackedScene

var attack_direction = Vector2.ZERO

@onready var launch_position: Marker2D = $LaunchPosition as Marker2D

var current_state: STATE = STATE.IDLE:
	get:
		return current_state
	set(value):
		match(value):
			STATE.IDLE:
				enemy_collision_hitbox.set_deferred("monitoring", true)
				can_be_hit = true
			STATE.ATTACK:
				enemy_collision_hitbox.set_deferred("monitoring", true)
				can_be_hit = true
				animation_tree.set('parameters/attack/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			STATE.HIT:
				enemy_collision_hitbox.set_deferred("monitoring", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				can_be_hit = false
				animation_tree['parameters/hit/request'] = true
				attack_timer.start()
		
		current_state = value
		
var attack_target

@onready var attack_timer: Timer = $AttackTimer as Timer
@onready var enemy_collision_hitbox: Area2D = $EnemyCollisionHitBox as Area2D

func _physics_process(delta):
	match(current_state):
		STATE.IDLE:
			waypoint_move(delta)
			
			if (is_instance_valid(attack_target) && attack_timer.is_stopped()):
				self.current_state = STATE.ATTACK
				attack_direction = self.position.direction_to(attack_target.position)
				attack_timer.start()
		STATE.ATTACK:
			waypoint_move(delta)
		
		
func _get_move_velocity(delta, direction):
	velocity = fly_speed * direction
	
func launch_projectile(target_direction):
	var launched_projectile = projectile.instantiate()
	launched_projectile.global_position = launch_position.global_position
	launched_projectile.rotation += target_direction.angle()
	get_tree().get_current_scene().add_child(launched_projectile)
	launched_projectile.target_direction = target_direction
	
func get_hit(damage: float):
	self.health -= damage
	self.current_state = STATE.HIT

func _hit_animation_finished():
	self.current_state = STATE.IDLE
	
func _attack_animation_finished():
	self.current_state = STATE.IDLE
	launch_projectile(attack_direction)

func _on_projectil_attack_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	attack_target = body

func _on_projectil_attack_area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	attack_target = null
