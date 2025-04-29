extends CharacterBody2D

@export var moving_forward_speed = 400
@export var moving_backward_speed = -300
@export var jumping_speed = -800
@export var give_jumping_speed = false
@export var in_action = false
@export var actionxspeed = 0
@export var actionyspeed = 0
@export var can_cancel = false
@export var can_hard_cancel = false
@export var can_super_cancel = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_player_1 = true
var xspeed = 0
var yspeed = 0
var input_data
var is_on_ground = false
var input_direction
var last_input_direction = ""


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var combo_manager: StateChart = $ComboManager


func _ready() -> void:
	animation_tree.active = true
	in_action = false
	
	if is_on_floor():
		is_on_ground = true
	else:
		is_on_ground = false

func _physics_process(delta: float) -> void:
	if InputSheet.is_frame_running:
		reset_animation()
		refresh()
		xspeed = velocity.x
		yspeed = velocity.y
	
	# 处理移动
		if not is_on_floor():
			pass
		elif not in_action:
			if input_data["8_direction"] == "null":
				xspeed = 0
				animation_tree["parameters/conditions/idle"] = true
			elif input_data["8_direction"] == "right":
				if input_data["is_left"]:
					xspeed = moving_forward_speed
					animation_tree["parameters/conditions/move_forward"] = true
				else:
					xspeed = -1 * moving_backward_speed
					animation_tree["parameters/conditions/move_backward"] = true
			elif input_data["8_direction"] == "left":
				if input_data["is_left"]:
					xspeed = moving_backward_speed
					animation_tree["parameters/conditions/move_backward"] = true
				else:
					xspeed = -1 * moving_forward_speed
					animation_tree["parameters/conditions/move_forward"] = true
			elif input_data["8_direction"] == "downleft":
				if input_data["is_left"]:
					xspeed = 0
					animation_tree["parameters/conditions/crouch"] = true
				else:
					xspeed = 0
					animation_tree["parameters/conditions/crouch"] = true
			elif input_data["8_direction"] == "downright":
				if input_data["is_left"]:
					xspeed = 0
					animation_tree["parameters/conditions/crouch"] = true
				else:
					xspeed = 0
					animation_tree["parameters/conditions/crouch"] = true
			elif input_data["8_direction"] == "down":
				if input_data["is_left"]:
					xspeed = 0
					animation_tree["parameters/conditions/crouch"] = true
				else:
					xspeed = 0
					animation_tree["parameters/conditions/crouch"] = true
			elif input_data["8_direction"] == "upright":
				if is_on_floor():
					if input_data["is_left"]:
						xspeed = moving_forward_speed
						animation_tree["parameters/conditions/jump"] = true
					else:
						xspeed = -1 * moving_backward_speed
						animation_tree["parameters/conditions/jump"] = true
			elif input_data["8_direction"] == "upleft":
				if is_on_floor():
					if input_data["is_left"]:
						xspeed = moving_backward_speed
						animation_tree["parameters/conditions/jump"] = true
					else:
						xspeed = -1 * moving_forward_speed
						animation_tree["parameters/conditions/jump"] = true
			elif input_data["8_direction"] == "up":
				if is_on_floor():
					xspeed = 0
					animation_tree["parameters/conditions/jump"] = true


		# 处理跳跃
		if give_jumping_speed:
			give_jumping_speed = false
			if is_on_floor():
				yspeed = jumping_speed

		# 重力
		if not is_on_floor():
			yspeed += gravity * delta
			is_on_ground = false
			if velocity.y > 0:
				animation_tree["parameters/conditions/fall"] = true
		else:
			handle_flip()
			is_on_ground = true
			animation_tree["parameters/conditions/fall"] = false
		
		if not in_action:
			velocity.x = xspeed
			velocity.y = yspeed
		else:
			if not input_data["is_left"]:
				actionxspeed *= -1
			velocity.x = actionxspeed
			velocity.y = actionyspeed
			xspeed = actionxspeed
			yspeed = actionxspeed
		
		move_and_slide()



# 处理人物翻转
func handle_flip():
	if input_data["is_left"]:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true

# 判断当前帧是否需要刷新
func refresh():
	# 检查是否有新输入
	if is_player_1:
		if InputSheet.player_1_current_frame in InputSheet.player_1_input_sheet:
			input_data = InputSheet.player_1_input_sheet[InputSheet.player_1_current_frame].duplicate(true)
			handle_combo()
	elif InputSheet.player_2_current_frame in InputSheet.player_2_input_sheet:
		input_data = InputSheet.player_2_input_sheet[InputSheet.player_2_current_frame].duplicate(true)
		handle_combo()
	
	# 检查是否刚着地
	if is_on_ground == false and is_on_floor():
		animation_tree["parameters/conditions/idle"] = true
		
	

func reset_animation():
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/crouch"] = false
	animation_tree["parameters/conditions/jump"] = false
	animation_tree["parameters/conditions/move_backward"] = false
	animation_tree["parameters/conditions/move_forward"] = false
	animation_tree["parameters/conditions/risesword"] = false
	animation_tree["parameters/conditions/strike1"] = false
	animation_tree["parameters/conditions/strike2"] = false
	animation_tree["parameters/conditions/punch"] = false
	animation_tree["parameters/conditions/kick"] = false
	animation_tree["parameters/conditions/hardstrike"] = false


func _on_risesword_state_processing(delta: float) -> void:
	if cancel_check("hard_cancel", false):
		animation_tree["parameters/conditions/risesword"] = true

func handle_combo():
	input_direction = input_data["8_direction"]
	if last_input_direction != input_direction:
		if input_data["is_left"]:
			combo_manager.send_event(input_direction)
		else:
			var combo_on_right = input_direction
			if "right" in combo_on_right:
				combo_on_right = combo_on_right.replace("right", "left")
			elif "left" in combo_on_right:
				combo_on_right = combo_on_right.replace("left", "right")
			combo_manager.send_event(combo_on_right)
			
	for action_name in ["punch", "kick", "strike", "hard_strike"]:
		if input_data[action_name]:
			combo_manager.send_event(action_name)

func cancel_check(cancel_type:String, is_tc:bool) -> bool:
	if not in_action and not is_tc:
		return true
	elif cancel_type == "cancel":
		if can_cancel:
			return true
	elif cancel_type == "hard_cancel":
		if can_hard_cancel:
			return true
	elif cancel_type == "super_cancel":
		if can_super_cancel:
			return true
	return false


func _on_strike_state_processing(delta: float) -> void:
	if cancel_check("none", false):
		animation_tree["parameters/conditions/strike1"] = true


func _on_strikestrike_state_processing(delta: float) -> void:
	if cancel_check("cancel", true):
		animation_tree["parameters/conditions/strike2"] = true


func _on_punch_state_processing(delta: float) -> void:
	if cancel_check("none", false):
		animation_tree["parameters/conditions/punch"] = true


func _on_kick_state_processing(delta: float) -> void:
	if cancel_check("none", false):
		animation_tree["parameters/conditions/kick"] = true


func _on_hardstrike_state_processing(delta: float) -> void:
	if cancel_check("none", false):
		animation_tree["parameters/conditions/hardstrike"] = true
