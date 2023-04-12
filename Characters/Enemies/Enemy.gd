class_name Enemy extends Character


@export var can_be_hit: bool = true
@export var collision_damage: float = 3

@export var waypoint_arrived_distance: float = 10
@export var faces_right: bool = true

@export var waypoints: Array[NodePath]
@export var starting_waypoint = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var waypoint_position: Vector2

@onready var waypoint_index = starting_waypoint:
	set(value):
		waypoint_index = value
		if (waypoints.size()>0):
			waypoint_position = get_node(waypoints[waypoint_index]).position

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	waypoint_index = self.starting_waypoint
	animated_sprite.play()

func _on_enemy_collision_hit_box_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	var player = body as Player
	player.get_hit(collision_damage)

func waypoint_move(delta):

	if (waypoints.size() > 0):	
		var direction = self.position.direction_to(waypoint_position)
		var distance_x = abs(self.position.x - waypoint_position.x)
		
		if (distance_x > waypoint_arrived_distance):
			_get_move_velocity(delta, direction)
			
			var direction_x_sign = sign(direction.x)
			if (direction_x_sign == -1):
				animated_sprite.flip_h = faces_right
			else:
				animated_sprite.flip_h = !faces_right
			
		else:
			var num_waypoints = waypoints.size()
			if (waypoint_index < num_waypoints-1):
				waypoint_index += 1
			else:
				waypoint_index = 0
		
		move_and_slide()

func _get_move_velocity(delta, direction):
	printerr("Get Move Velocity has not been Implemented")
