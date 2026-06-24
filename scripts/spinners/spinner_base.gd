extends MeshInstance3D
class_name SpinnerBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    prev_wheel_y = rotation_degrees.y
    
var machine_curve

@export var wheelSound: AudioStreamPlayer3D
@export var ticker_low_player: AudioStreamPlayer3D
@export var ticker_high_player: AudioStreamPlayer3D

@export var level_up_bar: MeshInstance3D
@export var ticker: MeshInstance3D
var ticker_high_next = true
var spin_speed = 4.0
var want_to_rebuild
var _rebuild_luck_store = 0
var seconds_to_adjust = 0
var rotated_clockwise = false

var last_rotation_y := 0.0
var active_spin_angular_velocity := 0.0

func update_spinner_velocity(delta: float):
    var current_rot = rotation.y
    active_spin_angular_velocity = wrapf(current_rot - last_rotation_y, -PI, PI) / delta
    last_rotation_y = current_rot


var wheel_angular_velocity = 0.0
var damping = 0.98
var fudging_base_strength = 1.0 #probably 0.3 for real game, level scales it not this (base * level)

var ticker_min_cooldown = 0.016
var ticker_cooldown = ticker_min_cooldown

var prev_wheel_y = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if(want_spin): #we spin
        wheel_angular_velocity = 0.0
        update_spinner_velocity(delta)
        #friction calculation
        if fudging:
            var force = 0.0
            var torque_multi = clamp(mouse_distance / 200, 0.0, 1.0) #more torque the further from center up to a point
            torque_multi = torque_multi * 4000
            var angle = get_mouse_angle()
            if angle != null and last_mouse_angle != null:
                var diff = wrapf(angle - last_mouse_angle, -PI, PI)
                force = diff * torque_multi #increase by mouse
            last_mouse_angle = angle
            
            
            var fudging_spin = false
            if((force < 0 and rotated_clockwise) or (force > 0 and not rotated_clockwise)):
                fudging_spin = true
        
            #we now use force to adjust seconds_to_spin
            var effective_time = clamp(seconds_to_spin, 1.0, 3.0)
            var fudge = abs(force * fudging_base_strength * (Globals.spin_friction*0.25) * effective_time * delta)
            if(fudging_spin):
                seconds_to_spin = max(seconds_to_spin - fudge, 0.0)
            else:
                seconds_to_spin = max(seconds_to_spin + fudge, 0.0)
            seconds_to_spin = min(seconds_to_spin, 10.0)
        #end friction calc
            
        if(rotated_clockwise):
            rotate_y((spin_speed * delta * ((seconds_to_spin*seconds_to_spin)/16)))
        else:
            rotate_y(-1 * (spin_speed * delta * ((seconds_to_spin*seconds_to_spin)/16)))
        seconds_to_spin -= delta
        if(seconds_to_spin <= 0): #we finish spinning
            want_spin = false
            seconds_to_adjust = 0.5
            
    elif(seconds_to_adjust > 0): #we settle
        wheel_angular_velocity = 0.0
        var target_adjustment_rad = deg_to_rad(snap_to_bucket_signed(rotation_degrees.y))
        var step = target_adjustment_rad * (delta / seconds_to_adjust)
        #prevent massive overshooting
        if abs(step) > abs(target_adjustment_rad):
            step = target_adjustment_rad
        rotate_y(step)
        seconds_to_adjust -= delta
        if(seconds_to_adjust <= 0.0): #we score
            result_slice = get_slice_from_bucket(get_bucket_index(rotation_degrees.y))
            slices[result_slice].callback.call()
            
    elif dragging: #we spin the wheel with the mouse
        var torque_multi = clamp(mouse_distance / 200, 0.0, 1.0)
        torque_multi = torque_multi * 4000
        var angle = get_mouse_angle()
        if angle != null and last_mouse_angle != null:
            var diff = wrapf(angle - last_mouse_angle, -PI, PI)
            drag_angular_velocity = diff / delta  # radians/sec
            rotate_y(wheel_angular_velocity * delta)
            wheel_angular_velocity *= damping #natural slow
            wheel_angular_velocity += diff * torque_multi #increase by mouse
        last_mouse_angle = angle   
    elif abs(wheel_angular_velocity) > 0.0001: #we spin the wheel for fun
        rotate_y(wheel_angular_velocity * delta)
        wheel_angular_velocity *= damping
            
    if(Globals.luck != _rebuild_luck_store): #rebuild wheel when luck gets updated
        rebuild_spinner()
        _rebuild_luck_store = Globals.luck
    #always do this per frame
    var diff = abs(rotation_degrees.y - prev_wheel_y)
    var deg_per_sec = diff / delta
    ticker_cooldown -= delta
    if(ticker_cooldown <= 0.0):
        if(ticker_crossed()):
            ticker_cooldown = ticker_min_cooldown
            var time_per_peg = 6.0 / deg_per_sec
            var playback_speed = clamp((0.2 / time_per_peg)/5, 1, 1)
            if(ticker_high_next):
                ticker_high_player.pitch_scale = playback_speed
                ticker_high_player.play()
            else:
                ticker_low_player.pitch_scale = playback_speed
                ticker_low_player.play()
            ticker_high_next = not ticker_high_next
    prev_wheel_y = rotation_degrees.y
    var mat = ticker.get_active_material(0) as ShaderMaterial
    var fake_rotation_y = rotation_degrees.y
    if(deg_per_sec > 40):
        fake_rotation_y = 72.0
        print(clockwise)
    mat.set_shader_parameter("wheel_angle_deg", fake_rotation_y)
    var clockwise_shader_val = -1.0 if clockwise else 1.0
    
    mat.set_shader_parameter("clockwise", clockwise_shader_val)

var clockwise = false
func ticker_crossed():
    var raw = rotation_degrees.y - prev_wheel_y
    var diff = fposmod(raw + 180.0, 360.0) - 180.0
    if(seconds_to_adjust <= 0.0 and seconds_to_spin <= 0.0): #to prevent the ticker flip at the end of a spin
        clockwise = diff > 0.0
    var boundary = snapped(prev_wheel_y, 6) #find closest pin
    
    if (clockwise and boundary < prev_wheel_y):
        boundary += 6
    elif(not clockwise and boundary > prev_wheel_y):
        boundary -= 6
        
    return (clockwise and boundary <= rotation_degrees.y) \
    or (not clockwise and boundary >= rotation_degrees.y)
    
    
func bias_angle(angle_deg):
    var biased_angle = angle_deg
    if(rotated_clockwise): #give the ticker a bit of a snapback effect based on the way it spinned
        biased_angle -= 1.0
    else:
        biased_angle += 1.0
    return biased_angle
    
func snap_to_bucket_signed(angle_deg: float) -> float:   #TODO bug where is flips around the axis of -180 to 180 or something
    var biased_angle = bias_angle(angle_deg)
    var center = 6.0 * round((biased_angle - 3.0) / 6.0) + 3.0
    #rotate_y snaps from -180 to 180
    center = fposmod(center + 180.0, 360.0) - 180.0
    return center - angle_deg
    
func get_bucket_index(angle_deg: float) -> int:
    var biased_angle = bias_angle(angle_deg-90.0) #adjust by 90 because idk DANGER
    var idx = round((biased_angle - 3.0) / 6.0)
    return wrapi(idx, 0, 60)
    
func get_slice_from_bucket(bucket_index: int) -> int:
    var running = 0
    for i in slices.size():
        var count = slices[i].buckets
        if bucket_index < running + count:
            return i
        running += count
    return -1 



signal spin_started
var experience_to_level_up = 0.0
var experience = 0.0
var base_experience_to_level_up = 100
var level = 1
var total_buckets = 0.0
var want_spin = false
var seconds_to_spin = 0.0
var chosen_angle = 0
var target_rad = 0
var result_slice = 0
var result_bucket = 0

func start_spin():    
    chosen_angle = randi() % 360 #pick somewhere on the circle
    want_spin = true
    Globals.total_spins += 1
    var full_spin_rads = TAU*8 * pow(0.9, Globals.spin_percision) #8 full spins + our target
    target_rad = (deg_to_rad(chosen_angle)+full_spin_rads)
    #print(target_rad)
    seconds_to_spin = compute_spin_time(target_rad) #we add 267 because -3 degree to the middle and 270 for the ticker placement
        
func compute_spin_time(target_angle):
    return pow((48.0 * target_angle) / spin_speed, 1.0/3.0)
      
func deg_to_rad(deg: float) -> float:
    return deg * (TAU / 360.0)
    
func rad_to_deg(rad: float) -> float:
    return rad * (360.0 / TAU)


func _on_spin_requested():
    if(want_spin):
        return #we are already spinning
    emit_signal("spin_started")
    start_spin()
  
var slices = []

#mouse drag and friction code
var dragging = false
var fudging = false
var last_mouse_angle = null
var drag_angular_velocity = 0.0
var cam_ref
var mouse_distance = 0.0

func get_mouse_angle() -> float:
    var viewport_size = get_viewport().get_visible_rect().size
    var mouse_pos = get_viewport().get_mouse_position()
    var wheel_screen_pos = cam_ref.unproject_position(global_transform.origin)

    var v = (mouse_pos - wheel_screen_pos) / viewport_size
    mouse_distance = v.length()

    return atan2(v.x, v.y)


func stop_dragging():
    if(dragging):
        dragging = false
        Globals.mouse_dragging = false
        check_for_spin()
        
func stop_fudging():
    if(fudging):
        Globals.mouse_fudging = false
        fudging = false

var spin_threshold = 15.0

func check_for_spin():
    if abs(wheel_angular_velocity) > spin_threshold - min(spin_threshold-5,(1 * Globals.spin_friction)):
        if(wheel_angular_velocity > 0.0):
            rotated_clockwise = true
        else:
            rotated_clockwise = false
        _on_spin_requested()
    
    
#end mouse drag

#mesh creation code below here
func add_slice(label, material, weight, callback):
    slices.append({
        "label": label, #label must be unique in the case of removing slices
        "material": material,
        "base_weight": weight,
        "weight": weight,
        "buckets": 0,
        "callback": callback
    })
    rebuild_spinner()
    
func remove_slice(label):
    slices = slices.filter(func(s): return s.label != label)
    rebuild_spinner()


func set_slices(new_slices):
    slices = new_slices
    rebuild_spinner()
    

func rebuild_spinner():
    var arrayMesh = ArrayMesh.new()
    arrayMesh.clear_surfaces()

    var odds = get_machine_odds(machine_curve)
    for slice in slices:
        var label = slice.label
        if odds.has(label):
            slice.weight = odds[label]
        else:
            slice.weight = slice.base_weight #just in case idk
            
    total_buckets = 60.0
    allocate_buckets()

    var radius = 1.0
    var segments = 16

    var angle = 0.0

    for slice in slices:
        var verts = PackedVector3Array()
        var indices = PackedInt32Array()
        #calculate per slice angle size
        var slice_angle = TAU * (slice.buckets / total_buckets)

        # center vert
        verts.append(Vector3.ZERO)
        #arc
        for i in range(segments + 1):
            var t = float(i) / segments
            var a = angle + t * slice_angle
            verts.append(Vector3(cos(a) * radius, 0, sin(a) * radius))
        #triangle
        for i in range(segments):
            indices.append_array([
                0,
                i + 1,
                i + 2 
            ])

        var normals = PackedVector3Array()
        for v in verts:
            normals.append(Vector3.UP) # or compute real normals
            
        var uvs = PackedVector2Array()

        #full circle is the UV
        #uvs.append(Vector2(0.5, 0.5))
#
        #for i in range(segments + 1):
            #var t = float(i) / segments
            #var a = angle + t * slice_angle
#
            ## Project onto square UV space
            #var ux = cos(a) * 0.5 + 0.5
            #var uy = sin(a) * 0.5 + 0.5
#
            #uvs.append(Vector2(ux, uy))
            
        #per slice UV
        uvs.append(Vector2(0.5, 0.0))

        for i in range(segments + 1):
            var t = float(i) / segments

            # Arc goes from left-bottom to right-bottom of texture
            var ux = t
            var uy = 1.0

            uvs.append(Vector2(ux, uy))





        var arrays = []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = verts
        arrays[Mesh.ARRAY_INDEX] = indices
        arrays[Mesh.ARRAY_NORMAL] = normals
        arrays[Mesh.ARRAY_TEX_UV] = uvs

        var surface_index = arrayMesh.get_surface_count()
        arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        arrayMesh.surface_set_material(surface_index, slice.material)
        angle += slice_angle


    mesh = arrayMesh


func get_machine_odds(curve: Dictionary):
    var capped_luck = min(Globals.luck, curve.luck_cap)
    var thresholds = curve.thresholds

    var a = thresholds[0]
    var b = thresholds[thresholds.size() - 1]

    for i in range(thresholds.size() - 1):
        if capped_luck >= thresholds[i].luck and capped_luck <= thresholds[i + 1].luck:
            a = thresholds[i]
            b = thresholds[i + 1]
            break

    var t = 0.0
    if b.luck != a.luck:
        t = (capped_luck - a.luck) / float(b.luck - a.luck)

    var results = {}
    for key in a.keys():
        if key != "luck":
            results[key] = lerp(a[key], b[key], t)

    return results


func allocate_buckets():
    var total := 0.0
    for s in slices:
        total += s.weight

    var fractional: Array[float] = []

    for i in range(slices.size()):
        var w = slices[i].weight
        var exact = 60.0 * (w / total)
        slices[i].buckets = int(round(exact))
        fractional.append(exact - floor(exact))

    var sum_buckets := 0
    for s in slices:
        sum_buckets += s.buckets
        
    while sum_buckets > 60:
        var idx := fractional.find(fractional.max())
        slices[idx].buckets -= 1
        fractional[idx] = 0
        sum_buckets -= 1
        
    while sum_buckets < 60:
        var idx := fractional.find(fractional.max())
        slices[idx].buckets += 1
        fractional[idx] = 0
        sum_buckets += 1
        
        
@export var money_box: Control
@export var floating_text: PackedScene   

func add_money(value):
    Globals.update_money(value)
    var text = floating_text.instantiate()
    money_box.add_child(text)

    text.position = Vector2(0, 0)
    text.show_value(value)
