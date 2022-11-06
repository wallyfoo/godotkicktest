extends CharacterBody2D


const SPEED := 300.0

const FRICTION := 0.25

@export_range (0, 200, 1) var inertia: int = 100

@export var jump_height := 100.0
@export var jump_time_to_peak := 0.5
@export var jump_time_to_descend := 0.4

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descend * jump_time_to_descend)) * -1

@onready var whack_multiplier : int = 750

enum {MOVE, JUMP, IDLE}

var state = IDLE

var input_vector := Vector2.ZERO
var aim := Vector2.ZERO

var detected_things : Array = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	Globals.player_instance = self
#	Globals.Things.append(self)
	@warning_ignore(return_value_discarded)
	Signals.connect("time_slow", time_slow_indicator_hide)
	@warning_ignore(return_value_discarded)
	Signals.connect("time_slow_reset_complete", time_slow_indicator_show)

func _physics_process(delta):
	
	calculate_aim()
	get_input_vector()
	gravity(delta)
	jump()
	whack()
	move_left_and_right(input_vector)
	apply_friction(input_vector)
	@warning_ignore(return_value_discarded)
	move_and_slide()
	check_idle(input_vector)
	update_animations(input_vector)
	
	
func get_input_vector() -> void:
#	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
func calculate_aim() -> void:
	
	aim.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	aim.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")

	if detected_things.size() > 0 and Globals.do_slow:
		if aim != Vector2.ZERO:
			detected_things[0].set_pointer(aim.angle())
		else:
			aim = global_position.direction_to(get_global_mouse_position())
			detected_things[0].set_pointer(aim.angle())
		

func apply_friction(_input_vector):
	if _input_vector.x == 0 and is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		
func gravity(delta) -> void:
	velocity.y += get_gravity() * delta
	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func move_left_and_right(_input_vector) -> void:
	if _input_vector:
		velocity.x = _input_vector.x * SPEED
		if is_on_floor():
			state = MOVE
	
func jump() -> void:
	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept") ) and is_on_floor():
		velocity.y = jump_velocity
		state = JUMP

func check_idle(_input_vector) -> void:
	if _input_vector:
		pass
	else:
		if is_on_floor():
			state = IDLE
		

func change_facing(_input_vector) -> void:
	var facing = sign(_input_vector.x)
	if facing != 0 and facing != $GFX.scale.x:
		$GFX.scale.x *= -1

func update_animations(_input_vector) -> void:
	
	change_facing(_input_vector)
	
	if !is_on_floor():
		state = JUMP
	
	match state:
		MOVE:
			$AnimationPlayer.play("walk")
		JUMP:
			$AnimationPlayer.play("jump")
		IDLE:
			$AnimationPlayer.play("idle")


func change_color(color) -> void:
	$GFX/Polygon2D.color = Color(color)


func _on_thing_detector_body_entered(body):
	if body.is_in_group("pushable"):
		change_color("red")
		body.whacked = false
		detected_things.append(body)

func whack(_wm = whack_multiplier) -> void:
	if (Input.is_action_just_pressed("whack") or Input.is_action_just_released("con_time_slow")) and detected_things.size() > 0:
		for thing in detected_things:
			if !thing.whacked:
				var multiplier = 1
				var rad
				var impulse_fix_factor = -1
				
				if Globals.do_slow:
					multiplier = 1.3
					
					if aim != Vector2.ZERO:
						rad = thing.get_aim_radians()
					else:
						rad = whack_direction()
						
					impulse_fix_factor = 1
					thing.sleeping = true
					
				else:
					rad = whack_direction()
				
				var impulse = Vector2.from_angle(rad) * _wm * multiplier
				impulse.y *= impulse_fix_factor
				
				thing.whacked = true
				thing.whack(impulse)
				

func whack_direction() -> float:
	var random_angle
	if sign($GFX.scale.x) == -1:
		random_angle = randi_range(135, 170)
	else:
		random_angle = randi_range(10, 45)
		
	return deg_to_rad(random_angle)

func _on_thing_detector_body_exited(body):
	if body.is_in_group("pushable"):
		change_color("white")
		var index = detected_things.find(body)
		if index > -1:
			detected_things[index].hide_pointer()
			detected_things.remove_at(index)

func time_slow_indicator_hide(_mode) -> void:
	$GFX/TimeSlowIndicator.visible = false

func time_slow_indicator_show() -> void:
	$GFX/TimeSlowIndicator.visible = true
