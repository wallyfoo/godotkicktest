extends Polygon2D

@onready var screen_size := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("can_see_thing", can_be_seen)
	var screen_rect = get_viewport_rect()
	screen_size.x = screen_rect.size.x - 100
	screen_size.y = screen_rect.size.y - 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_position()

func can_be_seen(_mode) -> void:
	visible = !_mode

func update_position() -> void:
	look_at(Globals.Things[0].global_position)
	global_position.x = clamp(Globals.player_instance.global_position.x + Globals.Things[0].global_position.x, (Globals.player_instance.global_position.x + screen_size.x/2 * -1), Globals.player_instance.global_position.x + screen_size.x/2)
	global_position.y = clamp(Globals.player_instance.global_position.y + Globals.Things[0].global_position.y, Globals.player_instance.global_position.y + screen_size.y/2 * -1, Globals.player_instance.global_position.y + screen_size.y/2)
	

