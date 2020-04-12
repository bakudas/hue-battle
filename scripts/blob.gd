extends RigidBody2D

var cor:Color
var facing:int

onready var texture_mask:PackedScene = preload("res://entities/texture_mask.tscn")
onready var player:Node2D = get_parent()

func _ready():
	cor = _pick_color()
#	facing = player.get_facing()
#	print("cor: " + String(cor) + " x,y: " + String(position))
	$Sprite.set_modulate(cor)
	
#	set_linear_velocity(get_linear_velocity() * facing)
	

func _physics_process(delta):
	var bodies:Array = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("wall"):
			var texture:Node2D = texture_mask.instance()
			texture.position = position
			get_tree().get_root().add_child(texture)
			texture.set_modulate(cor)
			queue_free()

func _pick_color() -> Color:
	var img:Image = get_viewport().get_texture().get_data()
	var cor:Color
	if img != null:
		img.flip_y()
		img.lock()
#		img.save_png("captures/teste_screen_cap.png")
	cor = img.get_pixel(position.x, position.y + 2)
	return cor

