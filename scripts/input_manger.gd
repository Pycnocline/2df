extends Control

const PI = 3.14

var current_frame = 0
var is_frame_running = false
var input_direction = "null"
var input_data = {
	"8_direction" : "null",
	"punch" : false,
	"kick" : false,
	"strike" : false,
	"hard_strike" : false
}
var input_data_sheet = {}
var is_left = true
var last_active_frame = 0

@onready var label_delta: Label = $Indicator/Label_Delta
@onready var label_current_frame: Label = $Indicator/Label_CurrentFrame
@onready var label_current_direction_input: Label = $Indicator/Label_CurrentDirectionInput
@onready var rich_text_label_input_data_sheet: RichTextLabel = $Indicator/RichTextLabel_Input_data_sheet
@onready var combo_manager: StateChart = $ComboManager
@onready var label_8_direction_input: Label = $Indicator/Label_8DirectionInput
@onready var label_is_left: Label = $Indicator/Label_IsLeft


func _ready() -> void:
	input_data_sheet[0] = input_data.duplicate(true)

func _physics_process(delta: float) -> void:
	if is_frame_running:
		current_frame += 1
		
		if "Delta:" + str(delta) != label_delta.text:
			label_delta.text = "Delta:" + str(delta)
		if "当前帧：" + str(current_frame) != label_current_frame.text:
			label_current_frame.text = "当前帧:" + str(current_frame)
	
	get_input()
	write_input_sheet()
	label_is_left.text = "在左侧:" + str(is_left)

func get_input():
	var last_input_direction = input_direction
	
	# 获取输入向量并标准化
	var input_direction_data = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	label_current_direction_input.text = "当前标准化方向输入:" + str(input_direction_data)
	
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
	label_8_direction_input.text = "8方向输入:" + str(input_direction)
	
	if last_input_direction != input_direction:
		if is_left:
			combo_manager.send_event(input_direction)
		else:
			var combo_on_right = input_direction
			if "right" in combo_on_right:
				combo_on_right = combo_on_right.replace("right", "left")
			elif "left" in combo_on_right:
				combo_on_right = combo_on_right.replace("left", "right")
			combo_manager.send_event(combo_on_right)
			
	for action_name in ["punch", "kick", "strike", "hard_strike"]:
		if Input.is_action_just_pressed(action_name):
			input_data[action_name] = true
			combo_manager.send_event(action_name)
		elif Input.is_action_just_released(action_name):
			input_data[action_name] = false

	
func write_input_sheet():
	if input_data != input_data_sheet[last_active_frame]:
		last_active_frame = current_frame
		input_data_sheet[current_frame] = input_data.duplicate(true)
		rich_text_label_input_data_sheet.text = str(input_data_sheet)


func _on_button_change_facing_pressed() -> void:
	is_left = !is_left


func _on_button_frame_control_pressed() -> void:
	is_frame_running = !is_frame_running
