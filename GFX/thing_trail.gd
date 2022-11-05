extends Line2D

var trail_size : int = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	@warning_ignore(return_value_discarded)
	Signals.connect("update_thing_trail", update_thing_trail)
	@warning_ignore(return_value_discarded)
	Signals.connect("delist_thing", clear_thing_trail)

func update_thing_trail(_pos: Vector2) -> void:
	add_point(_pos)
	if get_point_count() > trail_size:
		remove_point(0)


func clear_thing_trail(_thing) -> void:
	clear_points()
