extends Node

signal game_over()

var active_player: Player:
	set(value):
		if(active_player != value):
			if(is_instance_valid(active_player)):	
				active_player.disconnect('player_died', on_player_died)

		active_player = value
		if(is_instance_valid(value)):
			active_player.connect('player_died', on_player_died)
	get:
		return active_player
		
	
func on_player_died(player):
	game_over.emit()

