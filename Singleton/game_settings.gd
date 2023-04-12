extends Node

@export var gravity: float = 30
@export var terminal_velocity: float = 300
@export var should_randomize = true

@onready var RandomGen = RandomNumberGenerator.new()

func _ready():
	if (should_randomize):
		RandomGen.randomize()
