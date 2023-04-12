extends Area2D

@export var destination_scene: PackedScene

func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	
	print("ented shape")
	get_tree().change_scene_to_packed(destination_scene)


func _on_body_entered(body):
	GameManager.active_player = null
	get_tree().change_scene_to_packed(destination_scene)
