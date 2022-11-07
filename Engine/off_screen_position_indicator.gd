extends Polygon2D

const MARGIN := Vector2(100,100)

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
		var extents = ((rect.size - MARGIN) / 2)
		var extents_dir = extents * quad
		
		var m = rel.y/rel.x
		var y = (m * extents.x)
		var x = (extents.y/m)

		
		if abs(y) >= abs(extents.y):
			y = m * x
		else:
			x = y/m
#		print("X: ",x, " Y: ", y)
#		global_position = Globals.player_instance.global_position + Vector2(x,y)
		position = Vector2(x,y) + (extents)
		print("----------")
		print(Vector2(x,y))
		print(quad)
		print(extents)
		print(extents_dir)
		print(position)
#		global_position = (Globals.player_instance.global_position + Vector2(x,y))
		
		rotation = Vector2.ZERO.angle_to_point(rel)
