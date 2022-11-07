extends Polygon2D

const MARGIN := Vector2(150,150)

@onready var Canvas := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("can_see_thing", can_be_seen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_position()

func can_be_seen(_mode) -> void:
	visible = !_mode

func update_position() -> void:
	# to find a vector pointing from a -> b, use b-a
	if visible:

		var rect = get_viewport_rect()

		var rel = (Globals.Things[0].global_position - Globals.player_instance.global_position)
		var quad = Vector2(sign(rel.x), sign(rel.y))
		var extents = ((rect.size - MARGIN) / 2) * quad

		var m = rel.y/rel.x
		var y = (m * extents.x)
		var x = (extents.y/m)
		
		var distance = Globals.player_instance.global_position.distance_to(Globals.Things[0].global_position)
		
		var d_min = abs(extents.x)
		var d_scale = d_min/(distance - 100)
		
		scale = clamp(Vector2(1,1) * d_scale, Vector2(0.6,0.6), Vector2(1,1))

		if abs(y) >= abs(extents.y):
			y = m * x
		else:
			x = y/m
		global_position = Globals.player_instance.global_position + Vector2(x,y)
		look_at(Globals.Things[0].global_position)
