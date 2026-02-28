# PlayerState.gd
# Place this in res://scripts/states/PlayerState.gd
class_name PlayerState extends State

# State name constants — avoids typos when emitting finished()
const IDLE          := "Idle"
const RUN           := "Run"
const JUMP          := "Jump"
const FALL          := "Fall"
const CROUCH        := "Crouch"
const CROUCH_WALK   := "CrouchWalk"
const DASH          := "Dash"
const ROLL          := "Roll"
const SLIDE         := "Slide"
const ATTACK1       := "Attack1"
const ATTACK2       := "Attack2"
const ATTACK3       := "Attack3"
const CROUCH_ATTACK := "CrouchAttack"
const WALL_HANG     := "WallHang"
const WALL_CLIMB    := "WallClimb"
const HIT           := "Hit"
const DEATH         := "Death"

var player: Knight


func _ready() -> void:
	await owner.ready
	player = owner as Knight
	assert(player != null, "PlayerState must be used inside a Knight scene.")
