extends Label3D

var index := 0

func _ready():
    starting_rotation = camera.rotation.y
    intro_text = text
    ui.visible = false
    text = "Simulation loading...
Please wait..."

@export var camera: Camera3D
@export var intro: Node3D
@export var collision_blocker: CollisionShape3D
@export var ui: Control
var full_rotate = TAU
var starting_rotation
var reset = true
var show_text = false
var intro_text
func _process(delta):
    if(intro.visible == false): #skip intro if it is set to not visible
        intro.visible = false
        collision_blocker.disabled = true
        ui.visible = true
        return
    if(full_rotate > 0):
        camera.rotate_y(.05)
        full_rotate -= .05
    elif(reset):
        camera.rotation.y = starting_rotation
        reset = false
        show_text = true
    if(not reset and show_text):
        show_text = false
        reveal_text()
    
        
var speed = 0.1  #seconds between character
func reveal_text() -> void:
    for i in intro_text.length():
        text = intro_text.substr(0, i + 1)
        if(intro_text[i] == "\n"):  
            await get_tree().create_timer(1.0).timeout #stop between lines
        else:
            await get_tree().create_timer(speed).timeout
    intro.visible = false
    collision_blocker.disabled = true
    ui.visible = true
