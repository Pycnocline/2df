extends Control

@onready var linked_character_label: Label = $Player1VBoxContainer/LinkedCharacterLabel
@onready var current_frame_label: Label = $Player1VBoxContainer/CurrentFrameLabel
@onready var is_left_label: Label = $Player1VBoxContainer/IsLeftLabel
@onready var in_action_label: Label = $Player1VBoxContainer/InActionLabel
@onready var can_cancel_label: Label = $Player1VBoxContainer/CanCancelLabel
@onready var can_hard_cancel_label: Label = $Player1VBoxContainer/CanHardCancelLabel
@onready var can_super_cancel_label: Label = $Player1VBoxContainer/CanSuperCancelLabel
@onready var move_direction_label: Label = $Player1VBoxContainer/MoveDirectionLabel
@onready var punch_label: Label = $Player1VBoxContainer/PunchLabel
@onready var kick_label: Label = $Player1VBoxContainer/KickLabel
@onready var strike_label: Label = $Player1VBoxContainer/StrikeLabel
@onready var hard_strike_label: Label = $Player1VBoxContainer/HardStrikeLabel

@export var player1_character_body_2d : CharacterBody2D
@export var player2_character_body_2d : CharacterBody2D

func _physics_process(delta: float) -> void:
	pass

func indicate_player1():
	linked_character_label.text = player1_character_body_2d.get_path()
	current_frame_label.text = str(InputSheet.player_1_current_frame)
	is_left_label.text = str(InputSheet.player_1_input_sheet)
