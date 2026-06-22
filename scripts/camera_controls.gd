extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    next_machine_box.visible = Globals.viewing_spinner < Globals.max_viewable_spinner
    prev_machine_box.visible = Globals.viewing_spinner > 1
    omni_light.visible = Globals.spinner_unlocks[Globals.viewing_spinner-1]


    
func _physics_process(_delta: float) -> void:
    if active_spinner and active_spinner.want_spin:
        mouse_pos = get_viewport().get_mouse_position()


    if (want_click):
        raycast_from_screen(mouse_pos)
        want_click = false
    
var want_click = false
var mouse_pos
#ui and other audio
@export var ui_player: AudioStreamPlayer3D
@export var good_sound: AudioStream
@export var bad_sound: AudioStream


@export var area_light: AreaLight3D
@export var omni_light: OmniLight3D


#prev/next machine
@export var next_machine_box: HBoxContainer
@export var prev_machine_box: HBoxContainer
#mouse code
var holding_m1 = false
func _unhandled_input(event):
    if event.is_action_pressed("ui_left"):
        prev_machine()
    if event.is_action_pressed("ui_right"):
        next_machine()
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        mouse_pos = event.position
        want_click = true
        holding_m1 = true

    if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        holding_m1 = false
        if(active_spinner):
            active_spinner.stop_dragging()
            active_spinner.stop_fudging()
            active_spinner = null
            
func prev_machine():
    if(Globals.viewing_spinner > 1):
        Globals.viewing_spinner -= 1
        rotation_degrees.y += 90
    else:
        ui_player.stream = bad_sound
        ui_player.play()
        
    pass
    
func next_machine():
    if(Globals.viewing_spinner < Globals.max_viewable_spinner):
        Globals.viewing_spinner += 1
        rotation_degrees.y -= 90
    else:
        ui_player.stream = bad_sound
        ui_player.play()
    pass

func raycast_hits_spinner(screen_pos: Vector2) -> bool:
    cam = get_viewport().get_camera_3d()
    if cam == null:
        return false

    var origin = cam.project_ray_origin(screen_pos)
    var direction = cam.project_ray_normal(screen_pos)

    var space_state = get_viewport().get_world_3d().direct_space_state

    var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0)
    var result = space_state.intersect_ray(query)

    if result:
        var collider = result.collider
        if collider.name == "SpinnerCollision":
            return collider.get_parent() == active_spinner

    return false


var active_spinner
var cam
func raycast_from_screen(screen_pos: Vector2):
    cam = get_viewport().get_camera_3d()
    if cam == null:
        return

    var origin = cam.project_ray_origin(screen_pos)
    var direction = cam.project_ray_normal(screen_pos)


    var result = fat_raycast(screen_pos, 16.0, 12)

    if result:
        var collider = result.collider
        if collider.name == "SpinnerCollision":
            if(collider.get_parent() is SpinnerBase):
                if(Globals.spinner_unlocks[Globals.viewing_spinner-1]):
                    active_spinner = collider.get_parent()
                    if(not active_spinner.want_spin): #dragging
                        active_spinner.cam_ref = self
                        active_spinner.dragging = true
                        Globals.mouse_dragging = true
                        active_spinner.last_mouse_angle = null
                        active_spinner.drag_angular_velocity = 0.0
                    elif(active_spinner.want_spin): #fudging
                        active_spinner.cam_ref = self
                        active_spinner.fudging = true
                        Globals.mouse_fudging = true
                        active_spinner.last_mouse_angle = null
                        active_spinner.drag_angular_velocity = 0.0
                    else:
                        pass
        else:
            if(collider is SpinnerBuyButton):
                collider.attempt_buy()
                print(collider.name)
    else:
        print("no hit")
    
    
#credit random discord person
func fat_raycast(screen_pos: Vector2, radius := 6.0, rays := 8) -> Dictionary:
    if cam == null:
        return {}

    var space_state = get_viewport().get_world_3d().direct_space_state

    var origin = cam.project_ray_origin(screen_pos)
    var direction = cam.project_ray_normal(screen_pos)
    var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0)
    var result = space_state.intersect_ray(query)
    if result:
        return result

    for i in range(rays):
        var angle = TAU * float(i) / rays
        var offset = Vector2(cos(angle), sin(angle)) * radius
        var pos = screen_pos + offset

        origin = cam.project_ray_origin(pos)
        direction = cam.project_ray_normal(pos)
        query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0)

        result = space_state.intersect_ray(query)
        if result:
            return result

    return {}
