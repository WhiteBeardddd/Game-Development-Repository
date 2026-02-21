extends Node2D
const SPEED = 60
var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var right_ray_cast: RayCast2D = $RightRayCast
@onready var left_ray_cast: RayCast2D = $LeftRayCast
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta):
	if right_ray_cast.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
	if left_ray_cast.is_colliding():
		direction = 1		
		animated_sprite_2d.flip_h = false
		
	position.x += direction * SPEED * delta
