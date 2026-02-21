extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const SPEED = 130.0
const JUMP_VELOCITY = -175.0

# Dash settings
const DASH_SPEED = 130.0
const DASH_DURATION = 1
const DASH_COOLDOWN = 0.8

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 1.0

func _physics_process(delta: float) -> void:
	# Tick timers
	if dash_timer > 0:
		dash_timer -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Handle dash input
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		dash_direction = -1.0 if animated_sprite_2d.flip_h else 1.0

	# Stop dash when timer runs out
	if dash_timer <= 0 and is_dashing:
		is_dashing = false

	# If dashing, override everything
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		if animated_sprite_2d.animation != "dash":
			animated_sprite_2d.play("dash")
		move_and_slide()
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip sprite based on direction
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("default")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")

	# Handle movement
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _ready():
	add_to_group("player")
	call_deferred("set_spawn_position")

func set_spawn_position():
	if GameManager.spawn_point == "":
		return
	var spawn = get_tree().current_scene.get_node_or_null(GameManager.spawn_point)
	if spawn:
		global_position = spawn.global_position
	else:
		print("Spawn not found: ", GameManager.spawn_point)
