extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

    
func _physics_process(_delta: float) -> void:
    if active_spinner and active_spinner.want_spin:
        mouse_pos = get_viewport().get_mouse_position()
        if holding_m1 and raycast_hits_spinner(mouse_pos):
            active_spinner.fudging = true
            Globals.mouse_fudging = true
        else:
            active_spinner.stop_fudging()

        
            
    if (want_click):
        raycast_from_screen(mouse_pos)
        want_click = false
    
var want_click = false
var mouse_pos

#mouse code
var holding_m1 = false
func _unhandled_input(event):
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

    var space_state = get_viewport().get_world_3d().direct_space_state

    var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0)
    var result = space_state.intersect_ray(query)

    if result:
        var collider = result.collider
        if collider.name == "SpinnerCollision":
            if(collider.get_parent() is SpinnerBase):
                active_spinner = collider.get_parent()
                if(not active_spinner.want_spin):
                    #begin dragging it to try and spin
                    active_spinner.cam_ref = self
                    active_spinner.dragging = true
                    Globals.mouse_dragging = true
                    active_spinner.last_mouse_angle = null
                    active_spinner.drag_angular_velocity = 0.0
                elif(active_spinner.want_spin):
                    active_spinner.cam_ref = self
                    active_spinner.fudging = true
                    Globals.mouse_fudging = true
                    active_spinner.last_mouse_angle = null
                    active_spinner.drag_angular_velocity = 0.0
                else:
                    pass
                #emit_signal("spin_requested")
                #print("SPIN")
        else:
            print("pos:", result.position)
    else:
        print("no hit")
    
