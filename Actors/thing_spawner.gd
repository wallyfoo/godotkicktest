extends Node2D

@export var Thing: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	make_thing()
	Signals.connect("make_thing", make_thing)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func make_thing() -> void:
	var thing = Utils.instance_scene_on_main(Thing, position)
	Signals.emit_signal("list_thing", thing)
