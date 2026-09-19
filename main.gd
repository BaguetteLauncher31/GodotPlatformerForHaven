extends Node

@onready var player = $Player
@onready var play_area = $PlayArea
@onready var finish_line = $FinishLine
@onready var checkpoint = $Checkpoint
@onready var ui_label = $Player/StatusLabel
@onready var sfx_player = $SFXPlayer

var start_pos: Vector2
var time_alive = 0.0
var high_score = 0.0
var idle_time = 0.0
var prev_pos: Vector2
var has_left_start = false
var has_reached_checkpoint = false
var current_msg = ""
var fade_tween: Tween

func _ready():
	start_pos = player.global_position
	prev_pos = player.global_position
	
	play_area.body_exited.connect(_on_left_area)
	finish_line.body_entered.connect(_on_finish_line_entered)
	finish_line.body_exited.connect(_on_finish_line_exited)
	checkpoint.body_entered.connect(_on_checkpoint_entered)

func _process(delta):
	if has_left_start:
		time_alive += delta

		if player.global_position.distance_to(prev_pos) < 0.1:
			idle_time += delta
			if idle_time >= 1.0:
				respawn("Stood still too long.")
		else:
			idle_time = 0.0
	
	prev_pos = player.global_position
	update_ui()

func _on_left_area(body):
	if body == player:
		respawn("Out of Bounds!")

func _on_finish_line_exited(body):
	if body == player:
		has_left_start = true

func _on_checkpoint_entered(body):
	if body == player and has_left_start:
		has_reached_checkpoint = true

func _on_finish_line_entered(body):
	if body == player and has_left_start and has_reached_checkpoint:
		if high_score == 0.0 or time_alive < high_score:
			high_score = time_alive
		
		var final_time = round(time_alive * 10) / 10.0
		respawn("Lap complete! (" + str(final_time) + "s)")

func respawn(reason: String):
	player.global_position = start_pos
	time_alive = 0.0
	idle_time = 0.0
	prev_pos = start_pos
	has_left_start = false
	has_reached_checkpoint = false
	
	sfx_player.play()
	show_message_and_fade(reason)

func update_ui():
	var current_time = round(time_alive * 10) / 10.0
	var best_time = round(high_score * 10) / 10.0
	
	var text = "Time: " + str(current_time) + "s | Best: " + str(best_time) + "s"
	if current_msg != "":
		text += "\n" + current_msg
		
	ui_label.text = text

func show_message_and_fade(msg: String):
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	current_msg = msg
	ui_label.modulate.a = 1.0

	await get_tree().create_timer(2.0).timeout
	
	fade_tween = create_tween()
	fade_tween.tween_property(ui_label, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	
	current_msg = ""
	ui_label.modulate.a = 1.0
