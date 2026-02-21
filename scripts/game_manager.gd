extends Node

var spawn_point: String = ""
var score = 0

func add_points():
	score += 1
	print("+1 coin! Total coins: %d" % score)
