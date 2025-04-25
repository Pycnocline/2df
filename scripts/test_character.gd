extends CharacterBody2D

@export var moving_forward_speed = 400
@export var moving_backward_speed = -300
@export var jumping_speed = -800

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_player_1 = true
var input_data = {}
var current_frame
var xspeed = 0
var yspeed = 0
var frame_active = true
var on_floor_before = true


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if is_player_1:
		current_frame = InputSheet.player_1_current_frame
		input_data = InputSheet.player_1_input_sheet[0].duplicate(true)
	else:
		current_frame = InputSheet.player_2_current_frame
		input_data = InputSheet.player_2_input_sheet[0].duplicate(true)

func _physics_process(delta: float) -> void:
	if InputSheet.is_frame_running:
		handle_input_sheet()	
		
		# 重力
		if not is_on_floor():
			yspeed += gravity * delta
			on_floor_before = false
		else:
			handle_flip()
			
		if frame_active or is_on_floor() and not on_floor_before:
			# 处理移动
			if not is_on_floor():
				if velocity.y > 0:
					animation_player.play("Fall")
			else:
				frame_active = false
				if input_data["8_direction"] == "null":
					animation_player.play("Idle")
					xspeed = 0
				elif input_data["8_direction"] == "right":
					if input_data["is_left"]:
						xspeed = moving_forward_speed
						animation_player.play("move_forward")
					else:
						xspeed = -1 * moving_backward_speed
						animation_player.play("move_backward")
				elif input_data["8_direction"] == "left":
					if input_data["is_left"]:
						xspeed = moving_backward_speed
						animation_player.play("move_backward")
					else:
						xspeed = -1 * moving_forward_speed
						animation_player.play("move_forward")
				elif input_data["8_direction"] == "downleft":
					if input_data["is_left"]:
						xspeed = 0
						animation_player.play("Crouch")
					else:
						xspeed = 0
						animation_player.play("Crouch")
				elif input_data["8_direction"] == "downright":
					if input_data["is_left"]:
						xspeed = 0
						animation_player.play("Crouch")
					else:
						xspeed = 0
						animation_player.play("Crouch")
				elif input_data["8_direction"] == "down":
					if input_data["is_left"]:
						xspeed = 0
						animation_player.play("Crouch")
					else:
						xspeed = 0
						animation_player.play("Crouch")
				elif input_data["8_direction"] == "upright":
					if is_on_floor():
						if input_data["is_left"]:
							xspeed = moving_forward_speed
							yspeed = jumping_speed
							animation_player.play("Jump")
						else:
							xspeed = -1 * moving_backward_speed
							yspeed = jumping_speed
							animation_player.play("Jump")
				elif input_data["8_direction"] == "upleft":
					if is_on_floor():
						if input_data["is_left"]:
							xspeed = moving_backward_speed
							yspeed = jumping_speed
							animation_player.play("Jump")
						else:
							xspeed = -1 * moving_forward_speed
							yspeed = jumping_speed
							animation_player.play("Jump")
				elif input_data["8_direction"] == "up":
					if is_on_floor():
						if input_data["is_left"]:
							xspeed = 0
							yspeed = jumping_speed
							animation_player.play("Jump")
						else:
							xspeed = 0
							yspeed = jumping_speed
							animation_player.play("Jump")
		velocity.x = xspeed
		velocity.y = yspeed

		move_and_slide()
		


func handle_input_sheet():
	if is_player_1:
		current_frame = InputSheet.player_1_current_frame
		if current_frame in InputSheet.player_1_input_sheet:
			input_data = InputSheet.player_1_input_sheet[current_frame].duplicate(true)
			frame_active = true
	else:
		current_frame = InputSheet.player_2_current_frame
		if current_frame in InputSheet.player_2_input_sheet:
			input_data = InputSheet.player_2_input_sheet[current_frame].duplicate(true)
			frame_active = true

func handle_flip():
	if input_data["is_left"]:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
