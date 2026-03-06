extends Node2D

@onready var player: CharacterBody2D = $Player

const SKY_COLOR := Color("0b1720")
const MIST_COLOR := Color("183342")
const GROUND_COLOR := Color("2e4a39")
const COIL_COLOR := Color("6ee0b5")
const SPARK_COLOR := Color("ffc65c")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-960.0, -540.0, 1920.0, 1080.0), SKY_COLOR, true)
	draw_rect(Rect2(-960.0, -160.0, 1920.0, 300.0), MIST_COLOR, true)
	draw_rect(Rect2(-960.0, 140.0, 1920.0, 400.0), GROUND_COLOR, true)
	draw_rect(Rect2(80.0, 20.0, 280.0, 24.0), Color("7cbca2"), true)
	draw_circle(Vector2(-420.0, -60.0), 170.0, COIL_COLOR)
	draw_circle(Vector2(260.0, -120.0), 110.0, SPARK_COLOR)
	draw_rect(Rect2(-520.0, 112.0, 980.0, 20.0), Color("8fdac0"), true)
	draw_rect(Rect2(-620.0, 132.0, 44.0, 168.0), Color("264634"), true)
	draw_rect(Rect2(300.0, 132.0, 44.0, 168.0), Color("264634"), true)
	draw_line(Vector2(-470.0, -130.0), Vector2(360.0, 24.0), Color("d7fff0"), 9.0)
	draw_line(Vector2(-440.0, -178.0), Vector2(384.0, -20.0), Color("4bdca7"), 4.0)
	draw_line(Vector2(160.0, 30.0), Vector2(280.0, -82.0), Color("ffc65c"), 4.0)


func get_player() -> CharacterBody2D:
	return player
