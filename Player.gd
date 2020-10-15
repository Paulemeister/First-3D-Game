extends KinematicBody
export var v_mouse_sens = 1
export var h_mouse_sens = 1
export var max_speed = 10
export var movement_acceleration = 0.1
export var movement_damp: float = 5
export var jump_strength = 1
var jumped = false
var jump_duration = 1
export var gravity = 9.81
var grounded = false
var speed: Vector3 = Vector3(0,0,0) 
var acceleration: Vector3 = Vector3(0,0,0)
var distance: Vector3 = Vector3(0,0,0)

onready var HUD: Node
onready var SpeedLabel = []
onready var ForceLabel = []
onready var Camera
var time_passed = 0

func _input(event):
	if event is InputEventMouseMotion:
		Camera.rotation_degrees.x -= event.relative.y * v_mouse_sens
		Camera.rotation_degrees.x = clamp(Camera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * v_mouse_sens

func _ready():
	HUD = get_tree().get_current_scene().get_node("HUD")
	var axis = ["X","Y","Z"]
	for i in range(3):
		SpeedLabel.append(HUD.get_node("Info/Speed "+axis[i]))
		ForceLabel.append(HUD.get_node("Info/Force "+axis[i]))
	Camera = $Camera

	
func _physics_process(delta):
	
	var direction = Vector3(0,0,0)
	if Input.is_action_pressed("forward"):
			direction.x += 1
	elif Input.is_action_pressed("back"):
			direction.x += -1
	if Input.is_action_pressed("left"):
			direction.z += -1
	if Input.is_action_pressed("right"):
			direction.z += 1
	
	direction = direction.normalized()
	direction =direction.rotated(Vector3(0,1,0),self.rotation.y)
	
	speed += direction*movement_acceleration
	if direction.x == 0:
		speed.x /= movement_damp
	if direction.z == 0:
		speed.z /= movement_damp
	
	if not grounded:
		speed.y += -gravity
	else:
		if Input.is_action_pressed("jump"):
			speed.y += jump_strength
		else:
			speed.y = -0.1
	speed.x = clamp(speed.x,-max_speed,max_speed)
	speed.z = clamp(speed.z,-max_speed,max_speed)
	
	
	move_and_slide(speed,Vector3(0,1,0))
	grounded = is_on_floor()
	
func _process(delta):
	time_passed += delta
	if time_passed > 1/10:
		update_hud()
		time_passed = 0
	
func update_hud():
	var axis = ["X","Y","Z"]
	for i in range(3):
		SpeedLabel[i].set_text(axis[i]+ ": "+ str(self.speed[i]))
		ForceLabel[i].set_text(axis[i]+ ": "+ str(self.acceleration[i]))

