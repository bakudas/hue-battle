extends KinematicBody2D

signal color_effect_points(id, color)

const SPEED:int = 150
const FLOOR:Vector2 = Vector2(0, -1)
const GRAVITY:int = 300

var motion:Vector2 = Vector2()
export (float, 0.1, 1) var friction:float = .1
export (float, 0.1, 1) var acceleration:float= .25
export var jump_speed:int = -80
var can_jump:bool = false
var double_jump:bool = false
var facing:int = 1
var player_id:int
var color:Color = Color(1, 1, 1, 1)

onready var jump_particle:PackedScene = preload("res://entities/Jump_particles.tscn")
onready var blob_instance:PackedScene = preload("res://entities/blob.tscn")

func _ready():
	color = player_variables.color_effect["color"]
	$ColorRect.color = color
	player_variables.player_index += 1
	player_id = player_variables.player_index
	print("Jogador " + String(player_id) + " is ready to go!")

func _physics_process(delta):
	
#	$Line.points[2] = get_local_mouse_position()
	
#	#edge to edge
#	if position.x > get_viewport().size.x + $ColorRect.rect_size.x/2:
#		position.x = $ColorRect.rect_size.x/2
#	if position.x <= -8:
#		position.x = 320 - 8
	
	_controls(delta)
	
	var jmp_particle:Node2D = jump_particle.instance()
	if !is_on_floor():
		motion.y += GRAVITY * delta
		can_jump = false
		$ColorRect.rect_scale = lerp($ColorRect.rect_scale, Vector2(.75, 1.3), .2)
	else:
		can_jump = true
		$ColorRect.rect_scale = lerp($ColorRect.rect_scale, Vector2(1, 1), .4)
		if motion.y < 1 or motion.y < -1:
			jmp_particle.set_position(get_position() + Vector2(0, 12))
			get_tree().get_root().add_child(jmp_particle)
			jmp_particle.emitting = true
		else:
			jmp_particle.emitting = false
			
	#move the kinematic body
	move_and_slide(motion, FLOOR)

func _controls(delta) -> void:
	#setup var controls
	var up:bool
	var left:bool
	var right:bool
	var select:bool
	var atk:bool
	var cur_animation:String = $AnimationPlayer.get_current_animation()
	
	#check what player number
	match (player_id):
		_: 
			$Label.text = "P"+String(player_id)
#			$Label.set_modulate(ColorN)
			up = Input.is_action_just_pressed("p" + String(player_id) + "_up")
			left = Input.is_action_pressed("p" + String(player_id) + "_left")
			right = Input.is_action_pressed("p" + String(player_id) + "_right")
			select = Input.is_action_just_pressed("p" + String(player_id) + "_select")
			atk = Input.is_action_just_pressed("p" + String(player_id) + "_atk")

	#jump schema
	if up && can_jump:
		$AnimationPlayer.play("jump")
#		yield($AnimationPlayer,"animation_finished")
		motion.y = jump_speed * 2 #jump
		double_jump = true
	elif up && double_jump:
		$AnimationPlayer.play("jump")
		scale = lerp(Vector2(1, 1), Vector2(.6, 1.4), .1)
		motion.y = jump_speed * 1.5 #double jump
		double_jump = false
		
	#movements
	facing = 0
	if left:
		motion.x = -SPEED #vá para esquerda
		$Line.position.x = -5
		facing = -1
		if is_on_floor():
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.stop()
	elif right:
		motion.x = SPEED #vá para direita
		$Line.position.x = 5
		facing = 1
		if is_on_floor():
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.stop()
	elif motion.x != 0:
		motion.x = delta * facing
	if facing != 0:
		motion.x = lerp(motion.x, facing * SPEED, acceleration)
	else:
		motion.x = lerp(motion.x, 0, friction)
		
	#set idle animation
	if motion.x < 0.1 and motion.x > -0.1:
		$AnimationPlayer.play("idle")
	
	# attack trigger
	if atk:
		_throw_blobs()	
	
	# color switch trigger
	if select:
		player_variables.color_effect["color"] = _pick_color()
		var cor_temp:Color = player_variables.color_effect["color"]
		_set_color_rect(cor_temp)
		
		match (player_id):
			_:
				emit_signal("color_effect_points", player_id, cor_temp)

func _pick_color() -> Color:
	$ColorRect.visible = false
	var img:Image = get_viewport().get_texture().get_data()
	var cor:Color
	if img != null:
		img.flip_y()
		img.lock()
#		img.save_png("captures/teste_screen_cap.png")
	cor = img.get_pixel(position.x - 3, position.y - 3)
	$ColorRect.visible = true
	return cor
	
func _set_color_rect(color) -> void:
	$ColorRect.color = Color(color)
	
func _throw_blobs() -> void:
	var blob:Node2D = blob_instance.instance()
	blob.position = position
	get_tree().get_root().add_child(blob)

func get_facing() -> int:
	return facing
