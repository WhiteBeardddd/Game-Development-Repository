extends CharacterBody2D
class_name Player
signal HealthChanged

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const SPEED = 130.0
const JUMP_VELOCITY = -175.0
const DASH_SPEED = 130.0
const DASH_DURATION = 1
const DASH_COOLDOWN = 0.8

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 1.0

@export var MaxHealth: int = 30
var currentHealth: int
var isHurt: bool = false

func _ready():
	currentHealth = MaxHealth
	add_to_group("player")
	call_deferred("set_spawn_position")

func _physics_process(delta: float) -> void:
	if dash_timer > 0:
		dash_timer -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		dash_direction = -1.0 if animated_sprite_2d.flip_h else 1.0

	if dash_timer <= 0 and is_dashing:
		is_dashing = false

	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		if animated_sprite_2d.animation != "dash":
			animated_sprite_2d.play("dash")
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("default")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func set_spawn_position():
	if GameManager.spawn_point == "":
		return
	var spawn = get_tree().current_scene.get_node_or_null(GameManager.spawn_point)
	if spawn:
		global_position = spawn.global_position
	else:
		print("Spawn not found: ", GameManager.spawn_point)

func hurtByEnemy(_area):
	currentHealth -= 10
	currentHealth = max(currentHealth, 0)
	isHurt = true
	HealthChanged.emit()
