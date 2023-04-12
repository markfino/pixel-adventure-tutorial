extends Control

@onready var screen: Control = $Screen
@onready var timer: Timer = $Timer as Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	screen.visible = false
	GameManager.connect('game_over', _on_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_over():
	print("game_over")
	screen.visible = true
	screen.modulate = Color(1, 1, 1, 0)
	timer.start()

func _on_timer_timeout():
	screen.modulate = Color(1, 1, 1, 1)
