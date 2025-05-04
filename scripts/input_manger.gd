extends Control

const PI = 3.14

@export var single_player_control_type = false

var current_frame = 0
var is_frame_running = false
var input_direction = "null"
var input_data = {
	"is_player_1" : true,
	"is_left" : true,
	"8_direction" : "null",
	"punch" : false,
	"kick" : false,
	"strike" : false,
	"hard_strike" : false,
}
var input_data2 = {
	"is_player_1" : false,
	"is_left" : false,
	"8_direction" : "null",
	"punch" : false,
	"kick" : false,
	"strike" : false,
	"hard_strike" : false,
}

var input_data_sheet = {}
var input_data_sheet2 = {}
var last_active_frame = 0
var last_active_frame2 = 0

func _ready() -> void:
	input_data_sheet[0] = input_data.duplicate(true)
	input_data_sheet2[0] = input_data2.duplicate(true)
	apply_action()

func _physics_process(delta: float) -> void:
	if is_frame_running:
		current_frame += 1
	
	get_player1_input()
	get_player2_input()
	write_input_sheet()
	if is_frame_running:
		apply_action()
	InputSheet.is_frame_running = is_frame_running


func get_player1_input():
	var last_input_direction = input_direction
	
	# 获取输入向量并标准化
	var input_direction_data = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 吸附到8方向
	if input_direction_data == Vector2.ZERO:
		input_direction = "null"
	else:
		var input_direction_angle = input_direction_data.angle()
		#print(str(input_direction_angle))
		if PI/-8 <= input_direction_angle and input_direction_angle < PI/8:
			input_direction = "right"
		elif PI/8 <= input_direction_angle and input_direction_angle < 3*PI/8:
			input_direction = "downright"
		elif 3*PI/8 <= input_direction_angle and input_direction_angle < 5*PI/8:
			input_direction = "down"
		elif 5*PI/8 <= input_direction_angle and input_direction_angle < 7*PI/8:
			input_direction = "downleft"
		elif 7*PI/-8 <= input_direction_angle and input_direction_angle < 5*PI/-8:
			input_direction = "upleft"
		elif 5*PI/-8 <= input_direction_angle and input_direction_angle < 3*PI/-8:
			input_direction = "up"
		elif 3*PI/-8 <= input_direction_angle and input_direction_angle < PI/-8:
			input_direction = "upright"
		else:
			input_direction = "left"
	
	input_data["8_direction"] = input_direction
			
	for action_name in ["punch", "kick", "strike", "hard_strike"]:
		if Input.is_action_just_pressed(action_name):
			input_data[action_name] = true
		elif Input.is_action_just_released(action_name):
			input_data[action_name] = false

func get_player2_input():
	var last_input_direction = input_direction
	
	# 获取输入向量并标准化
	var input_direction_data = Input.get_vector("move_left2", "move_right2", "move_up2", "move_down2")
	
	# 吸附到8方向
	if input_direction_data == Vector2.ZERO:
		input_direction = "null"
	else:
		var input_direction_angle = input_direction_data.angle()
		#print(str(input_direction_angle))
		if PI/-8 <= input_direction_angle and input_direction_angle < PI/8:
			input_direction = "right"
		elif PI/8 <= input_direction_angle and input_direction_angle < 3*PI/8:
			input_direction = "downright"
		elif 3*PI/8 <= input_direction_angle and input_direction_angle < 5*PI/8:
			input_direction = "down"
		elif 5*PI/8 <= input_direction_angle and input_direction_angle < 7*PI/8:
			input_direction = "downleft"
		elif 7*PI/-8 <= input_direction_angle and input_direction_angle < 5*PI/-8:
			input_direction = "upleft"
		elif 5*PI/-8 <= input_direction_angle and input_direction_angle < 3*PI/-8:
			input_direction = "up"
		elif 3*PI/-8 <= input_direction_angle and input_direction_angle < PI/-8:
			input_direction = "upright"
		else:
			input_direction = "left"
	
	input_data2["8_direction"] = input_direction
			
	for action_name in ["punch2", "kick2", "strike2", "hard_strike2"]:
		if Input.is_action_just_pressed(action_name):
			input_data2[action_name.left(action_name.length() - 1)] = true
		elif Input.is_action_just_released(action_name):
			input_data2[action_name.left(action_name.length() - 1)] = false

	
func write_input_sheet():
	if input_data != input_data_sheet[last_active_frame] or InputSheet.is_frame_running != is_frame_running:
		last_active_frame = current_frame
		input_data_sheet[current_frame] = input_data.duplicate(true)
	if input_data2 != input_data_sheet2[last_active_frame2] or InputSheet.is_frame_running != is_frame_running:
		last_active_frame2 = current_frame
		input_data_sheet2[current_frame] = input_data.duplicate(true)
	

func apply_action():
		InputSheet.player_1_input_sheet = input_data_sheet.duplicate(true)
		InputSheet.player_1_current_frame = current_frame
		InputSheet.player_2_input_sheet = input_data_sheet2.duplicate(true)
		InputSheet.player_2_current_frame = current_frame
		print(input_data2)



func _on_button_frame_control_pressed() -> void:
	is_frame_running = !is_frame_running
