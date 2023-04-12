extends Control

@export var sprite_width: int = 18

@onready var texture_rect: TextureRect = $TextureRect as TextureRect

func _ready():
	
#	if (is_instance_valid(active_player)):
#		active_player.connect('health_changed', _on_health_changed)
#		texture_rect.size.x = sprite_width * active_player.health
	
#	GameManager.connect('game_over', _on_game_over)
	GameManager.game_over.connect(_on_game_over)
	
	on_new_player()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_health_changed(new_health):
	texture_rect.size.x = sprite_width * new_health

func _on_game_over():
	texture_rect.visible = false

func on_new_player():
	var active_player: Player = GameManager.active_player as Player
	active_player.connect('health_changed', _on_health_changed)
	texture_rect.size.x = sprite_width * active_player.health
