extends Camera3D


@export var dust_instance: CPUParticles3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    cam = get_viewport().get_camera_3d()
    dust_instance.emitting = false
    last_particle_pos = Vector3(0.0,0.0,0.0)
    last_mouse_pos = Vector2(0.0,0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    next_machine_box.visible = Globals.viewing_spinner < Globals.max_viewable_spinner
    prev_machine_box.visible = Globals.viewing_spinner > 1
    omni_light.visible = Globals.spinner_unlocks[Globals.viewing_spinner-1]

func get_particle_direction() -> Vector3:
    var v = hit_position - last_particle_pos
    if v.length() < 0.001:
        return Vector3.ZERO
    return v.normalized()
    
func get_mouse_speed(delta: float) -> float:
    var v = mouse_pos - last_mouse_pos
    return v.length() / delta
    
func get_dust_intensity(delta: float) -> float:
    var spin_speed = abs(active_spinner.active_spin_angular_velocity) * 0.1
    var mouse_speed = get_mouse_speed(delta) * 1.0
    var total_speed = (spin_speed + mouse_speed) * (Globals.spin_friction/20.0) / 500.0
    return clamp(total_speed, 0.0, 10.0)
    
func apply_dust_intensity(intensity: float):
    dust_instance.initial_velocity_max = 0.1 + intensity * 2.0
    dust_instance.initial_velocity_max = 0.5 + intensity * 2.0
    dust_instance.scale_amount_min = 0.0 + intensity * 0.05
    dust_instance.scale_amount_max = 0.1 + intensity * 0.1


var last_mouse_pos
var last_particle_pos
func _physics_process(delta: float) -> void:
    if active_spinner and active_spinner.want_spin:
        mouse_pos = get_viewport().get_mouse_position()
        if holding_m1 and raycast_hits_spinner(mouse_pos):
            active_spinner.fudging = true
            Globals.mouse_fudging = true
            #spawn particles
            dust_instance.global_position = hit_position
            #var moving = hit_position.distance_to(last_particle_pos) > 0.05
            dust_instance.emitting = true
            if(not drag_player.playing):
                drag_player.play()
            var intensity = get_dust_intensity(delta)
            apply_dust_intensity(get_dust_intensity(delta))
            drag_player.volume_db = clamp(intensity*6-24,-24.0,3.0) #intensity ranges typically from 0 - 3
            var dir = get_particle_direction()
            if dir != Vector3.ZERO:
                dust_instance.look_at(dust_instance.global_position + dir, Vector3.UP)
            last_particle_pos = hit_position
        else:
            active_spinner.stop_fudging()
            dust_instance.emitting = false
            drag_player.stop()
        last_mouse_pos = mouse_pos
    else:
        dust_instance.emitting = false
        drag_player.stop()
    if (want_click):
        raycast_from_screen(mouse_pos)
        want_click = false

    
var want_click = false
var mouse_pos
#ui and other audio
@export var ui_player: AudioStreamPlayer3D
@export var drag_player: AudioStreamPlayer3D
@export var good_sound: AudioStream
@export var bad_sound: AudioStream


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


var hit_position 
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
        hit_position = result.position
        var collider = result.collider
        if collider.name == "SpinnerCollision":
            return collider.get_parent() == active_spinner

    return false

@export var rainbow_spinner: SpinnerBase
var active_spinner : SpinnerBase
var cam
func raycast_from_screen(screen_pos: Vector2):
    if cam == null:
        return

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
            if(collider is StaticBody3D):
                if(collider.name == "rainbow_cashout"):
                    rainbow_spinner.cash_out()
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
