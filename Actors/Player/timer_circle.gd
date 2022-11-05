extends Node2D

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	@warning_ignore(return_value_discarded)
	Signals.connect("time_slow", do_slow)
	@warning_ignore(return_value_discarded)
	Signals.connect("start_reset_timer", start_reset_timer)
	@warning_ignore(return_value_discarded)
	Signals.connect("reset_after_whack", bounce_out)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !$SlowDuration.is_stopped() and $TextureProgressBar.value > 0:
		$TextureProgressBar.value = ($SlowDuration.time_left / $SlowDuration.wait_time) * 100
	
func do_slow(_mode: bool) -> void:
	if _mode:
		bounce_in()
	else:
		bounce_out()

func bounce_in() -> void:
	$TextureProgressBar.value = 100
	if tween:
		tween.stop()
	tween = create_tween()
	@warning_ignore(return_value_discarded)
	tween.set_parallel(true)
	modulate = Color(1,1,1,0)
	scale = Vector2(0.5,0.5)
	@warning_ignore(return_value_discarded)
	tween.tween_property(self, "scale", Vector2(1,1), 0.3).set_trans(Tween.TRANS_ELASTIC)
	@warning_ignore(return_value_discarded)
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.1)
#	tween.tween_callback($SlowDuration.start)

func bounce_out() -> void:
	tween.stop()
	tween = create_tween()
	@warning_ignore(return_value_discarded)
	tween.set_parallel(true)
	@warning_ignore(return_value_discarded)
	tween.tween_property(self, "scale", Vector2(), 0.2)
	@warning_ignore(return_value_discarded)
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.2)
	@warning_ignore(return_value_discarded)
	tween.tween_callback(reset_slow)

	
func reset_slow() -> void:
	if !$SlowDuration.is_stopped():
		$SlowDuration.stop()
	@warning_ignore(return_value_discarded)
	Signals.emit_signal("reset_slow")

func start_reset_timer() -> void:
	if $SlowDuration.is_stopped():
		$SlowDuration.start()
	

func _on_slow_duration_timeout():
	bounce_out()
