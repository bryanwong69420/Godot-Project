extends CharacterBody2D

const ACCELERATION = 800
const FRICTION = 500
const MAX_SPEED = 120
const JUMP_VELOCITY = -500
enum {IDLE, RUN, JUMP, ATTACK1}
var state = IDLE

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = [
	"parameters/idle/idle_bs2d/blend_position",
	"parameters/run/run_bs2d/blend_position",
	"parameters/jump/jump_bs2d/blend_position",
	"parameters/attack/attack1_bs2d/blend_position"
]
var animTree_state_keys = [
	"idle",
	"run",
	"jump",
	"attack1"
]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_attacking = false

func _physics_process(delta):
	move(delta)
	animate()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if state != JUMP and not is_attacking:
			state = JUMP
	elif state == JUMP and is_on_floor():
		state = IDLE
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state = JUMP
	if Input.is_action_just_pressed("attack1") and not is_attacking:
		state = ATTACK1
		is_attacking = true

func move(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		if is_on_floor():
			state = IDLE
		apply_friction(FRICTION * delta)
	else:
		if is_on_floor():
			state = RUN
		apply_movement(input_vector * ACCELERATION * delta)
		blend_position = input_vector
	move_and_slide()

func apply_friction(amount) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(amount) -> void:
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

func animate() -> void:
	state_machine.travel(animTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)
	
