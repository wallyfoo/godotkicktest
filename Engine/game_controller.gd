extends Node2D

@onready var slow_factor_min := 0.1
@onready var slow_factor_max := 1.0
@onready var slow_factor_interval := 0.01
@onready var slow_factor := slow_factor_max
@onready var do_slow := false

var can_slow := true


# Called when the node enters the scene tree for the first time.
func _ready():
	@warning_ignore(return_value_discarded)
	Signals.connect("reset_slow", reset_slow)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("time_slow") and can_slow:
		@warning_ignore(return_value_discarded)
		Signals.emit_signal("time_slow", true)
		set_do_slow(true)
		can_slow = false
	if Input.is_action_just_released("time_slow") and do_slow:
		@warning_ignore(return_value_discarded)
		Signals.emit_signal("time_slow", false)
		set_do_slow(false)
		
	time_slow()



func time_slow() -> void:
	if do_slow and Engine.time_scale > slow_factor_min:
		Engine.time_scale -= slow_factor_interval
		if Engine.time_scale <= slow_factor_min:
			@warning_ignore(return_value_discarded)
			Signals.emit_signal("start_reset_timer")
	elif Engine.time_scale < slow_factor_max:
		Engine.time_scale += slow_factor_interval
		if Engine.time_scale > slow_factor_max:
			Engine.time_scale = slow_factor_max
	

func reset_slow() -> void:
	set_do_slow(false)
	$SlowReset.start()


func set_do_slow(mode:bool) -> void:
	do_slow = mode
	Globals.do_slow = mode

func _on_slow_reset_timeout():
	can_slow = true
	@warning_ignore(return_value_discarded)
	Signals.emit_signal("time_slow_reset_complete")

