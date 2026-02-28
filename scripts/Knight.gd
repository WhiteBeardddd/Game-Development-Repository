# Knight.gd
# Attach to your CharacterBody2D root node
class_name Knight extends CharacterBody2D

# --- Tunable Stats ---
@export var speed        := 180.0
@export var jump_velocity:= -400.0
@export var gravity      := 900.0
@export var dash_speed   := 400.0
@export var roll_speed   := 300.0
@export var wall_slide_speed := 60.0
@export var wall_climb_speed := -120.0

# --- Combo ---
const COMBO_WINDOW := 0.6
var attack_combo   := 0
var combo_timer    := 0.0

# --- Nodes ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)


func _on_anim_finished() -> void:
	match anim.animation:
		"attack1":
			# Combo buffered? Go to attack2, otherwise idle
			if attack_combo == 2:
				attack_combo = 0
				$StateMachine._on_state_finished("Attack2")
			else:
				attack_combo = 0
				$StateMachine._on_state_finished("Idle")
		"attack2", "attack3", "crouch_attack":
			attack_combo = 0
			$StateMachine._on_state_finished("Idle")
		"roll":
			$StateMachine._on_state_finished("Idle")
		"slide":
			$StateMachine._on_state_finished("Idle")
		"hit":
			$StateMachine._on_state_finished("Idle")
		"dash":
			$StateMachine._on_state_finished("Idle")


# --- Helpers used by states ---
func play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func apply_horizontal(dir: float) -> void:
	if dir != 0.0:
		velocity.x = dir * speed
		anim.flip_h = dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)


# --- External API ---
func take_hit() -> void:
	$StateMachine._on_state_finished("Hit")


func die() -> void:
	$StateMachine._on_state_finished("Death")
