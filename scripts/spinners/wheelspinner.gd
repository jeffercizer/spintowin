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
    base_experience_to_level_up = get_flat_pos()
    experience_to_level_up = base_experience_to_level_up * (level * level)
    machine_curve = {
        "luck_cap": 10,
        "thresholds": [
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 5.0, "2xmulti": 20.0, "4xmulti": 20.0,  "2x_extra_spin": 20.0, "4x_extra_spin": 20.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 5.0, "2xmulti": 20.0, "4xmulti": 20.0,  "2x_extra_spin": 20.0, "4x_extra_spin": 20.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
        ]
    }
    #goodness can be used to have certain slices grow faster than their base weight would encourage
    #my idea is so we can make jackpots super super rare but become very doable
    add_slice("extra_spin", freespinMat, 1.0, Callable(self, "extra_spin")) 
    add_slice("flatnegative", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("flatpositive", winMaterial, 1.0, Callable(self, "flat_pos")) 
    add_slice("flatnegative", loseMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("bigflatpos", bigWinMaterial, 1.0, Callable(self, "big_flat_pos"))
    add_slice("flatnegative", loseMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("2xmulti", multi2xMat, 1.0, Callable(self, "multi_2x"))
    add_slice("flatnegative", loseMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("4xmulti", multi4xMat, 1.0, Callable(self, "multi_4x"))  
    add_slice("smallflatnegative", loseMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("2x_extra_spin", free2xspinMat, 1.0, Callable(self, "extra_spin_2")) 
    add_slice("smallflatnegative", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("4x_extra_spin", free4xspinMat, 1.0, Callable(self, "extra_spin_4")) 
    add_slice("smallflatnegative", loseMaterial, 1.0, Callable(self, "default_lose"))
    super._ready()
    


    
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
    if(spinning >= 0):
        payout_label.modulate.a = 1.0
        payout_label.outline_modulate.a = 1.0
        payout_label.text = "$"+ str(flat_value * multi_value)
        payout_label.font_size = (flat_value * multi_value)/get_flat_pos()
        var rot = sin(t) * 30.0
        payout_label.rotation_degrees.y = rot
    if(spinning == 0 and waiting_to_payout):
        payout()
        waiting_to_payout = false
        var tween = get_tree().create_tween()
        tween.tween_property(payout_label, "modulate:a", 0.0, 1.0)
        tween = get_tree().create_tween()
        tween.tween_property(payout_label, "outline_modulate:a", 0.0, 1.0)
    
var prev_seconds = 1.0
func _physics_process(_delta: float) -> void:
    if(spinning <= 0.0):
        super._physics_process(_delta) 
    
func evaluate_wheel():
    result_slice = get_slice_from_bucket(get_bucket_index(rotation_degrees.y))
    slices[result_slice].callback.call()
    #result_slice = get_slice_from_bucket(get_bucket_index(rotation_degrees.y+90))
    #slices[result_slice].callback.call()
    
    waiting_to_payout = true

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
    return -50000000000000.0 #50T

var waiting_to_payout = false
var spinning = 0.0
var flat_value = 0.0    
var multi_value = 0.0

var spinners: Array[MiniSpinner]
@export var mini_spinner1: MiniSpinner
@export var mini_spinner2: MiniSpinner
@export var mini_spinner3: MiniSpinner
@export var mini_spinner4: MiniSpinner
@export var mini_spinner5: MiniSpinner
@export var mini_spinner6: MiniSpinner
@export var mini_spinner7: MiniSpinner


func payout():
    print("payout")
    add_money(flat_value * multi_value)
    flat_value = 0.0
    multi_value = 0.0
    
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
    flat_value += get_flat_pos() * 10.0
    wheelSound.stream = winSound
    wheelSound.play()
    pass
    
func multi_2x():
    multi_value += 2.0
    pass
    
func multi_4x():
    multi_value += 4.0
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
