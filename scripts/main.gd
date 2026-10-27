extends Node2D

@export var health: int = 100
@export var speed: float = 280.0
@export var target_position := Vector2(760.0, 300.0)
@export var target_radius: float = 30.0
@export var player_radius: float = 28.0

@onready var player: Node2D = $Player
@onready var status: Label = $Status
@onready var info: Label = $Info

var elapsed_seconds: float = 0.0
var score: int = 0
var target_collected: bool = false
var game_won: bool = false


func _ready() -> void:
	_refresh_ui()
	queue_redraw()


func _process(delta: float) -> void:
	elapsed_seconds += delta
	if not game_won:
		var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		player.position += movement * speed * delta
		player.position.x = clampf(player.position.x, 80.0, 880.0)
		player.position.y = clampf(player.position.y, 170.0, 490.0)
		_check_target()
	_refresh_ui()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color("0b1220"))
	for x in range(0, 961, 40):
		draw_line(Vector2(x, 150), Vector2(x, 540), Color(0.1, 0.16, 0.24, 0.55), 1.0)
	for y in range(160, 541, 40):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.1, 0.16, 0.24, 0.55), 1.0)
	draw_rect(Rect2(Vector2(32, 145), Vector2(896, 360)), Color(0.06, 0.1, 0.16, 0.6), false, 2.0)
	if not target_collected:
		draw_circle(target_position, target_radius + 12.0, Color(1.0, 0.74, 0.25, 0.12))
		draw_circle(target_position, target_radius, Color("ffca58"))
		draw_circle(target_position, 16.0, Color("fff1a6"))
		draw_line(target_position - Vector2(20, 0), target_position + Vector2(20, 0), Color("fff7cf"), 3.0)
		draw_line(target_position - Vector2(0, 20), target_position + Vector2(0, 20), Color("fff7cf"), 3.0)
	else:
		draw_circle(target_position, target_radius, Color("66e3a4"))
		draw_line(target_position - Vector2(14, 0), target_position + Vector2(14, 0), Color("d8ffe9"), 3.0)
		draw_line(target_position - Vector2(0, 14), target_position + Vector2(0, 14), Color("d8ffe9"), 3.0)
	draw_circle(player.position, 28.0, Color("58d6ff"))
	draw_circle(player.position, 18.0, Color("12304a"))
	draw_line(player.position - Vector2(10, 0), player.position + Vector2(10, 0), Color.WHITE, 2.0)
	draw_line(player.position - Vector2(0, 10), player.position + Vector2(0, 10), Color.WHITE, 2.0)


func _mcp_state() -> Dictionary:
	return {
		"player_position": player.position,
		"target_position": target_position,
		"health": health,
		"score": score,
		"target_collected": target_collected,
		"game_won": game_won,
		"elapsed_seconds": elapsed_seconds,
		"scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
	}


func _check_target() -> void:
	if not target_collected and player.position.distance_to(target_position) <= target_radius + player_radius:
		collect_target()


func collect_target() -> int:
	if target_collected:
		return score
	target_collected = true
	score = 1
	game_won = true
	return score


func reset_game() -> void:
	player.position = Vector2(180.0, 300.0)
	score = 0
	target_collected = false
	game_won = false
	elapsed_seconds = 0.0
	_refresh_ui()
	queue_redraw()


func _refresh_ui() -> void:
	if game_won:
		status.text = "MVP COMPLETE | STAR COLLECTED | Runtime Bridge: online"
		info.text = "You win! score=%d  |  Run the scene again to reset." % score
	else:
		status.text = "COLLECT THE STAR | score=%d | Runtime Bridge: online" % score
		info.text = "Arrow keys move the blue player to the gold target  |  health=%d  |  position=%s" % [health, player.position]


func damage(amount: int = 10) -> int:
	health = maxi(health - amount, 0)
	return health
