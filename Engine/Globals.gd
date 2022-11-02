extends Node

var do_slow := false

var player_instance: CharacterBody2D = null

var Things : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("list_thing", list_thing)
	Signals.connect("delist_thing", delist_thing)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.


func list_thing(thing:RigidBody2D) -> void:
	Things.append(thing)
	
func delist_thing(thing:RigidBody2D) -> void:
	var index = Things.find(thing)
	if index > -1:
		Things.remove_at(index)
