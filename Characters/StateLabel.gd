extends Label


func _on_player_changed_state(new_state_str, new_state_id):
	self.text = str(new_state_str)
