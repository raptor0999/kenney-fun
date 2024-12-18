extends CharacterBody3D

const LERP_VALUE : float = 0.15

var walk_speed = 5.0
var run_speed = 8.0
var speed = walk_speed
var JUMP_VELOCITY = 4.5

@onready var playerMesh:Node3D = $characterSmall
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
@onready var horPivot:Node3D = $CamRoot/HorizontalPivot
@onready var springArm:SpringArm3D = $CamRoot/HorizontalPivot/VerticalPivot/SpringArm3D

var state
var punching = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		horPivot.rotate_y(-event.relative.x * 0.005)
		springArm.rotate_x(-event.relative.y * 0.005)
		springArm.rotation.x = clamp(springArm.rotation.x, -PI/8, PI/8)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("run"):
		state = "run"
	else:
		state = "walk"
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and not punching:
		state = "jump"
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("punch") and not punching and is_on_floor():
		punching = true
		animationPlayer.play("ImportedLib/punch")
		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animationPlayer.play("ImportedLib/jump")

	# Handle jump.
	if state == "jump":
		animationPlayer.play("ImportedLib/jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left")
	input_dir.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	input_dir = input_dir.rotated(Vector3.UP, horPivot.rotation.y)
	
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if input_dir:
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if input_dir:
		playerMesh.rotation.y = lerp_angle(playerMesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
		
	if is_on_floor() and not punching:
		if state == "run":
			animationPlayer.play("ImportedLib/run")
			speed = run_speed
			
		if state == "walk":
			animationPlayer.play("ImportedLib/walk")
			speed = walk_speed
			
		if velocity.length() < 0.1:
			state = "idle"
			animationPlayer.play("ImportedLib/idle")

	move_and_slide()

func stopPunching():
	punching = false
