class_name Player extends Character

@export var speed: float = 175
@export var jump_impulse: float = 500
@export var enemy_bounce_impulse: float = 400
@export var max_jumps: int = 2
@export var jump_damage: float = 1
@export var knockback_speed: float = 50
@export var wall_slide_friction: float = 0.5

signal changed_state(new_state_string, new_state_id)
signal player_died(player)
signal health_changed(new_health)

enum STATE {
	IDLE, RUN, JUMP, DOUBLE_JUMP, HIT, WALL_SLIDE
}

var current_state = STATE.IDLE
var jumps: int = 0
var is_bordering_wall: bool = false
var wall_jump_direction: Vector2

@onready var animation_tree = $AnimationTree as AnimationTree
@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var jump_hitbox = $JumpHitbox as Area2D
@onready var invincible_timer = $InvincibleTimer as Timer
@onready var wall_jump_timer = $WallJumpTimer as Timer
@onready var drop_timer = $DropTimer as Timer

func _ready():
	$AnimatedSprite2D.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var input = get_player_input()
	
	if (Input.is_action_just_pressed("ui_down")):
		if (drop_timer.is_stopped()):
			drop_timer.start()
		else:
			drop()
	
	
	move_and_slide()
	
	is_bordering_wall = get_is_on_wall_raycast_test()
	set_anim_parameters()
	
	match(self.current_state):
		STATE.IDLE, STATE.RUN, STATE.JUMP, STATE.DOUBLE_JUMP:
			if (wall_jump_timer.is_stopped()):
				normal_move(input)
			else:
				wall_jump_move()
				
			pick_next_state()
		STATE.HIT:
			hit_move() 
		STATE.WALL_SLIDE:
			wall_slide_and_move()
			pick_next_state()
			
	
func normal_move(input):
	adjust_flip_direction(input)
	
	velocity = Vector2(
		input.x * speed,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	
func drop():
	position.y += 5
	
func hit_move():
	var knockback_direction: Vector2
	if (animated_sprite.flip_h):
		knockback_direction = Vector2.RIGHT
	else:
		knockback_direction = Vector2.LEFT
	
	velocity = knockback_speed * knockback_direction.normalized()
	
func wall_slide_and_move():
	velocity = Vector2(
		velocity.x,
		min(velocity.y + (GameSettings.gravity * wall_slide_friction), GameSettings.terminal_velocity)
	)
	
func wall_jump_move():
	return Vector2(
		speed * wall_jump_direction.x,
		min(velocity.y + (GameSettings.gravity * wall_slide_friction), GameSettings.terminal_velocity)
	)

func get_hit(damage: float):
	if (invincible_timer.is_stopped()):
		
		if (damage >= self.health):
			player_died.emit(self)
			queue_free()
		
		self.health -= damage
		set_current_state(STATE.HIT)
		invincible_timer.start()
		health_changed.emit(self.health)
		
func _on_hit_finished():
	set_current_state(STATE.IDLE)
		
func adjust_flip_direction(input: Vector2):
	if(sign(input.x) == 1):
		animated_sprite.flip_h = false
	elif (sign(input.x) == -1):
		animated_sprite.flip_h = true
		
func set_anim_parameters():
	animation_tree.set("parameters/x_sign/blend_position", sign(velocity.x))
	animation_tree.set("parameters/y_sign/blend_amount", sign(velocity.y))	
	
	var is_on_wall_int: int
	if (get_is_on_wall_raycast_test() && !is_on_floor()):
#	if (current_state == STATE.WALL_SLIDE ):
		is_on_wall_int = 1
	else:
		is_on_wall_int = 0
		
	animation_tree.set("parameters/is_on_wall/blend_amount", is_on_wall_int)

func pick_next_state():
	
	if(is_on_floor()):
		jumps = 0
		if (Input.is_action_just_pressed("ui_up")):
			self.set_current_state(STATE.JUMP)
		elif (abs(velocity.x) > 0):
			self.set_current_state(STATE.RUN)
		else:
			self.set_current_state(STATE.IDLE)
	elif (Input.is_action_just_pressed("ui_up") and jumps < max_jumps):
		if (is_bordering_wall):
			self.set_current_state(STATE.JUMP)
		else:
			self.set_current_state(STATE.DOUBLE_JUMP)
	elif (is_bordering_wall):
		self.set_current_state(STATE.WALL_SLIDE)
	elif (self.current_state == STATE.WALL_SLIDE && !is_bordering_wall):
		self.set_current_state(STATE.JUMP)
	
	
func get_player_input():
	var input: Vector2 = Vector2(0, 0)	
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	return input

func set_current_state(new_state: STATE):
	match(new_state):
		STATE.JUMP:
			if (current_state == STATE.WALL_SLIDE):
				# there are multiple ways to enter the jump state
				if (Input.is_action_just_pressed("ui_up")):
					wall_jump()
			else:
				jump()
		STATE.DOUBLE_JUMP:
			jump()
			animation_tree.set("parameters/double_jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		STATE.HIT:
			animation_tree.set("parameters/hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		STATE.WALL_SLIDE:
			jumps = 0
	
	current_state = new_state
	
	changed_state.emit(STATE.keys()[new_state], new_state)

func jump():
	velocity.y = -jump_impulse
	jumps += 1
	
func wall_jump():
	velocity.y = -jump_impulse
	jumps = 1
	wall_jump_direction = -get_facing_direction()
	wall_jump_timer.start()
	
func get_facing_direction():
	if (animated_sprite.flip_h == false):
		return Vector2.RIGHT
	else:
		return Vector2.LEFT	
	
func get_is_on_wall_raycast_test():
	var space_state = get_world_2d().direct_space_state

	#todo up to here
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + 12 * get_facing_direction(), self.collision_mask, [self])
	var result = space_state.intersect_ray(query)

	if (result.size() > 0):
		return true
	else:
		return false
		
#	return is_on_wall()

func _on_jump_hitbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):

#	25 is that magic number that makes it work, I am not sure why maybe to do with hitbox size?
#	print("hit")	
#	print("jump HB:" + str(jump_hitbox.global_position.y))
#	print("Pig HB:" + str(area.global_position.y))

	if (area.owner is Enemy):
		var enemy = area.owner as Enemy
		if (enemy.can_be_hit):
			if (velocity.y > 0):
				#jump attack
				velocity.y = -enemy_bounce_impulse
				enemy.get_hit(jump_damage)

func die():
	player_died.emit(self)

func _on_animation_player_tree_entered():
	GameManager.active_player = self
