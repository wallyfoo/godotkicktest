extends RigidBody2D

@onready var original_mass := mass

var whacked := false

var skip_tick := 2
var tick := 0
var offset := Vector2(0, -3)

var snap: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("reset_slow", reset_slow)
	Signals.connect("reset_slow", hide_pointer)
	Signals.connect("time_slow", start_slow_snap)
	set_snap()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Signals.emit_signal("update_thing_trail", global_position)
	if position.y > 1000:
		Signals.emit_signal("make_thing")
		Signals.emit_signal("delist_thing", self)
		queue_free()

func start_slow_snap(mode) -> void:
	$FreezeJiggle.emitting = true
	if mode:
		if !snap.av:
			set_snap(get_angular_velocity(), get_linear_velocity())
		freeze = true

func reset_slow() -> void:
	$FreezeJiggle.emitting = false
	if freeze:
		freeze = false
		sleeping = false
		resume()

func resume() -> void:
	set_linear_velocity(snap.lv)
	set_angular_velocity(snap.av)
	set_snap()

func whack(impulse: Vector2) -> void:
	$FreezeJiggle.emitting = false
	freeze = false
	apply_impulse(impulse, offset)
	Signals.emit_signal("reset_slow")
	set_snap()
	

func set_pointer(angle) -> void:
	if !whacked:
		$Pointer.global_rotation = angle
		if !$Pointer.visible:
			$Pointer.visible = true

func hide_pointer() -> void:
	$Pointer.visible = false
	whacked = false
	
func get_aim_radians() -> float:
	return $Pointer.global_rotation

func set_snap(av = null, lv = null) -> void:
	snap = {"av": av, "lv": lv}
