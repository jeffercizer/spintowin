extends SpinnerBase
class_name WheelSpinner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spinners = [
        mini_spinner1,
        mini_spinner2,
        mini_spinner3,
        mini_spinner4,
        mini_spinner5,
        mini_spinner6,
        mini_spinner7
    ]
    base_experience_to_level_up = get_flat_pos() * 2
    experience_to_level_up = base_experience_to_level_up * (level * level)
    machine_curve = {
        "luck_cap": 20,
        "thresholds": [
            { "luck": 1,  "extra_spin": 5.0, "flatpositive": 10.0, "bigflatpos": 5.0, "flatnegative": 10.0, "smallflatnegative": 5.0, "2xmulti": 10.0, "4xmulti": 0.0,  "2x_extra_spin": 5.0, "4x_extra_spin": 0.0},
            { "luck": 12,  "extra_spin": 5.0, "flatpositive": 10.0, "bigflatpos": 5.0, "flatnegative": 10.0, "smallflatnegative": 5.0, "2xmulti": 10.0, "4xmulti": 0.0,  "2x_extra_spin": 5.0, "4x_extra_spin": 0.0},
            { "luck": 13,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 5.0, "flatnegative": 10.0, "smallflatnegative": 5.0, "2xmulti": 10.0, "4xmulti": 5.0,  "2x_extra_spin": 10.0, "4x_extra_spin": 5.0},
            { "luck": 16,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 10.0, "4x_extra_spin": 5.0},
            { "luck": 18,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 5.0, "smallflatnegative": 5.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 20.0, "4x_extra_spin": 10.0},
            { "luck": 20,  "extra_spin": 5.0, "flatpositive": 10.0, "bigflatpos": 20.0, "flatnegative": 0.0, "smallflatnegative": 0.0, "2xmulti": 10.0, "4xmulti": 20.0,  "2x_extra_spin": 10.0, "4x_extra_spin": 20.0},
        ]
    }
    add_slices()
    super._ready()
    
    
func add_slices():
    var slices_defs = [
        { "label": "flatnegative",      "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "flatnegative",      "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "flatnegative",      "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "flatnegative",      "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "smallflatnegative", "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "smallflatnegative", "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "smallflatnegative", "mat": loseMaterial,  "weight": 1.0, "callback": Callable(self, "default_lose") },
        { "label": "flatpositive",      "mat": winMaterial,   "weight": 1.0, "callback": Callable(self, "flat_pos") },
        { "label": "flatpositive",      "mat": winMaterial,   "weight": 1.0, "callback": Callable(self, "flat_pos") },
        { "label": "flatpositive",      "mat": winMaterial,   "weight": 1.0, "callback": Callable(self, "flat_pos") },
        { "label": "flatpositive",      "mat": winMaterial,   "weight": 1.0, "callback": Callable(self, "flat_pos") },
        { "label": "bigflatpos",        "mat": bigWinMaterial,"weight": 1.0, "callback": Callable(self, "big_flat_pos") },
        { "label": "bigflatpos",        "mat": bigWinMaterial,"weight": 1.0, "callback": Callable(self, "big_flat_pos") },
        { "label": "2xmulti",           "mat": multi2xMat,    "weight": 1.0, "callback": Callable(self, "multi_2x") },
        { "label": "2xmulti",           "mat": multi2xMat,    "weight": 1.0, "callback": Callable(self, "multi_2x") },
        { "label": "4xmulti",           "mat": multi4xMat,    "weight": 1.0, "callback": Callable(self, "multi_4x") },
        { "label": "extra_spin",        "mat": freespinMat,   "weight": 1.0, "callback": Callable(self, "extra_spin") },
        { "label": "extra_spin",        "mat": freespinMat,   "weight": 1.0, "callback": Callable(self, "extra_spin") },
        { "label": "extra_spin",        "mat": freespinMat,   "weight": 1.0, "callback": Callable(self, "extra_spin") },
        { "label": "extra_spin",        "mat": freespinMat,   "weight": 1.0, "callback": Callable(self, "extra_spin") },
        { "label": "2x_extra_spin",     "mat": free2xspinMat, "weight": 1.0, "callback": Callable(self, "extra_spin_2") },
        { "label": "2x_extra_spin",     "mat": free2xspinMat, "weight": 1.0, "callback": Callable(self, "extra_spin_2") },
        { "label": "4x_extra_spin",     "mat": free4xspinMat, "weight": 1.0, "callback": Callable(self, "extra_spin_4") },
    ]

    slices_defs.shuffle()

    for slice in slices_defs:
        add_slice(slice.label, slice.mat, slice.weight, slice.callback)
    rebuild_spinner()

    


    
#denominators are 1 2 3 4 5 6 10 12 15 20 30 60 for total weights to fit buckets
@export var winMaterial: ShaderMaterial
@export var bigWinMaterial: ShaderMaterial
@export var loseMaterial: ShaderMaterial
@export var freespinMat: ShaderMaterial
@export var free2xspinMat: ShaderMaterial
@export var free4xspinMat: ShaderMaterial
@export var multi2xMat: ShaderMaterial
@export var multi4xMat: ShaderMaterial


@export var level_label: Label3D

@export var loseSound: AudioStream
@export var winSound: AudioStream
@export var jackpotSound: AudioStream

@export var coin_animator: AnimationPlayer

@export var payout_label: Label3D

var t = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    t += delta
    if(spinning > 0):
        print("----------")
        payout_label.modulate.a = 1.0
        payout_label.outline_modulate.a = 1.0
        print(flat_value)
        print(multi_value)
        payout_label.text = "$"+ Globals.format_number(flat_value * multi_value)
        payout_label.font_size = clamp((flat_value * multi_value)/get_flat_pos(), 32, 256)
        var rot = sin(t) * 30.0
        payout_label.rotation_degrees.y = rot
    if(spinning == 0 and waiting_to_payout):
        payout()
        waiting_to_payout = false
        var tween = get_tree().create_tween()
        tween.tween_property(payout_label, "modulate:a", 0.0, 1.0)
        
        tween = get_tree().create_tween()
        tween.tween_property(payout_label, "outline_modulate:a", 0.0, 1.0)
        
        tween = get_tree().create_tween()
        tween.tween_interval(2.0) 
        tween.tween_callback(func():
            remove_allslices()
            add_slices()
        )
    
@export var l_ticker: MeshInstance3D
@export var r_ticker: MeshInstance3D
var prev_seconds = 1.0
func _physics_process(_delta: float) -> void:
    if(spinning <= 0.0):
        super._physics_process(_delta) 
    var l_mat = l_ticker.get_active_material(0) as ShaderMaterial
    var r_mat = r_ticker.get_active_material(0) as ShaderMaterial
    var fake_rotation_y = rotation_degrees.y
    if(deg_per_sec > 40):
        fake_rotation_y = 72.0
    l_mat.set_shader_parameter("wheel_angle_deg", fake_rotation_y+90)
    r_mat.set_shader_parameter("wheel_angle_deg", fake_rotation_y-90)
    var clockwise_shader_val = -1.0 if clockwise else 1.0
    l_mat.set_shader_parameter("clockwise", clockwise_shader_val)
    r_mat.set_shader_parameter("clockwise", clockwise_shader_val)
    
func evaluate_wheel():
    result_slice = get_slice_from_bucket(get_bucket_index(rotation_degrees.y))
    slices[result_slice].callback.call()
    result_slice = get_slice_from_bucket(get_bucket_index(rotation_degrees.y+90))
    slices[result_slice].callback.call()
    result_slice = get_slice_from_bucket(get_bucket_index(rotation_degrees.y-90))
    slices[result_slice].callback.call()
    waiting_to_payout = true
    var tween = get_tree().create_tween()



func start_spin(spin_num_mod):
    super.start_spin(spin_num_mod)
    
func _on_spin_requested() -> void:
    if(want_spin):
        return #we are already spinning
    emit_signal("spin_started")
    start_spin(0)
    
func wheel_finished(flat_amount, multiplier_amount):
    spinning -= 1
    flat_value += flat_amount
    multi_value += multiplier_amount
    
    
func add_experience(amount):
    if(amount <= 0):
        return
    experience += amount
    var mat := level_up_bar.get_active_material(0)

    while(experience >= experience_to_level_up):
        experience -= experience_to_level_up
        level += 1
        experience_to_level_up = base_experience_to_level_up * (level * level)
        
    mat.set_shader_parameter("progress", experience/experience_to_level_up)
    level_label.text = str(level)

    
func get_flat_pos(): 
    return 5000000000000.0 * pow(Globals.level_effect, level) #5T
    
func get_flat_negative():
    return -5000000000000.0 #5T

var waiting_to_payout = false
var spinning = 0.0
var flat_value = 0.0    
var multi_value = 1.0

var spinners: Array[MiniSpinner]
@export var mini_spinner1: MiniSpinner
@export var mini_spinner2: MiniSpinner
@export var mini_spinner3: MiniSpinner
@export var mini_spinner4: MiniSpinner
@export var mini_spinner5: MiniSpinner
@export var mini_spinner6: MiniSpinner
@export var mini_spinner7: MiniSpinner


func payout():
    add_money(flat_value * multi_value)
    add_experience(flat_value * multi_value)
    flat_value = 0.0
    multi_value = 1.0
    
#wheel specific callbacks
func default_lose():
    flat_value += get_flat_negative()
    wheelSound.stream = loseSound
    wheelSound.play()
    pass
    
func flat_pos():
    flat_value += get_flat_pos()
    wheelSound.stream = winSound
    wheelSound.play()
    pass
    
func big_flat_pos():
    flat_value += get_flat_pos() * 10.0 #50T
    wheelSound.stream = winSound
    wheelSound.play()
    pass
    
func multi_2x():
    multi_value *= 2.0
    pass
    
func multi_4x():
    multi_value *= 4.0
    pass
    
func extra_spin():
    spinners[spinning].start_spin((randi()%80)-40)
    spinning += 1
    pass
    
func extra_spin_2():
    for i in 2:
        spinners[spinning].start_spin((randi()%80)-40)
        spinning += 1
    pass
    
func extra_spin_4():
    for i in 4:
        spinners[spinning].start_spin((randi()%80)-40)
        spinning += 1
    pass
    
    
func _on_luck_button_button_up() -> void:
    want_to_rebuild = true
