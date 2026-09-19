extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite = $Sprite2D

var spin_state = 0 
var spin_speed = 10.0 
var spin_timer = 0.0
var next_change_time = 0.0

func _ready():
	pick_next_spin_interval()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	spin_timer += delta
	if spin_timer >= next_change_time:
		evaluate_spin_state()
	if spin_state != 0:
		sprite.rotation += spin_state * spin_speed * delta

func evaluate_spin_state():
	var choices = [0, 1, -1]
	spin_state = choices[randi() % choices.size()]
	pick_next_spin_interval()

func pick_next_spin_interval():
	spin_timer = 0.0
	next_change_time = randf_range(4.0, 8.0)
