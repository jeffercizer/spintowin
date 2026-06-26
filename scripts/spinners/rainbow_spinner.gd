extends SpinnerBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    payout_label.text = Globals.format_number(get_payout())
    base_experience_to_level_up = base_payout * 2
    experience_to_level_up = base_experience_to_level_up * (level * level)
    machine_curve = {
        "luck_cap": 16,
        "thresholds": [
            { "luck": 1,  "red": 1.0, "orange": 1.0, "yellow": 1.0, "green": 1.0, "blue": 1.0, "indigo":1.0, "violet":1.0, "black":10.0, "rainbow":0.0},
            { "luck": 7, "red": 1.0, "orange": 1.0, "yellow": 1.0, "green": 1.0, "blue": 1.0, "indigo":1.0, "violet":1.0, "black":10.0, "rainbow":0.0},
            { "luck": 8, "red": 5.0, "orange": 5.0, "yellow": 5.0, "green": 5.0, "blue": 5.0, "indigo":5.0, "violet":5.0, "black":10.0, "rainbow":1.0},
            { "luck": 10, "red": 10.0, "orange": 10.0, "yellow": 10.0, "green": 10.0, "blue": 10.0, "indigo":10.0, "violet":10.0, "black":10.0, "rainbow":5.0},
            { "luck": 14, "red": 20.0, "orange": 20.0, "yellow": 20.0, "green": 20.0, "blue": 20.0, "indigo":20.0, "violet":20.0, "black":5.0, "rainbow":15.0},
            { "luck": 16, "red": 7.0, "orange": 7.0, "yellow": 7.0, "green": 7.0, "blue": 7.0, "indigo":7.0, "violet":7.0, "black":0.0, "rainbow":50.0},
        ]
    }
    #goodness can be used to have certain slices grow faster than their base weight would encourage
    #my idea is so we can make jackpots super super rare but become very doable
    add_slice("red", redMaterial, 1.0, Callable(self, "red_win")) 
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("orange", orangeMaterial, 1.0, Callable(self, "orange_win"))
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("yellow", yellowMaterial, 1.0, Callable(self, "yellow_win")) 
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("green", greenMaterial, 1.0, Callable(self, "green_win")) 
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("blue", blueMaterial, 1.0, Callable(self, "blue_win"))
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("indigo", indiMaterial, 1.0, Callable(self, "indigo_win")) 
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("violet", violetMaterial, 1.0, Callable(self, "violet_win"))
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
    add_slice("rainbow", rainbowMaterial, 1.0, Callable(self, "rainbow_win")) 
    add_slice("black", blackMaterial, 1.0, Callable(self, "black_lose"))
        
    super._ready()
    
    
#denominators are 1 2 3 4 5 6 10 12 15 20 30 60 for total weights to fit buckets
@export var redMaterial: ShaderMaterial
@export var orangeMaterial: ShaderMaterial
@export var yellowMaterial: ShaderMaterial
@export var greenMaterial: ShaderMaterial
@export var blueMaterial: ShaderMaterial
@export var indiMaterial: ShaderMaterial
@export var violetMaterial: ShaderMaterial
@export var rainbowMaterial: ShaderMaterial
@export var blackMaterial: ShaderMaterial

@export var level_label: Label3D

@export var loseSound: AudioStream
@export var winSound: AudioStream
@export var jackpotSound: AudioStream

@export var payout_label: Label3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    
func _physics_process(_delta: float) -> void:
    super._physics_process(_delta)

func start_spin(spin_num_mod):
    super.start_spin(spin_num_mod)
    
func _on_spin_requested() -> void:
    if(want_spin):
        return #we are already spinning
    emit_signal("spin_started")
    start_spin(0)
    
    
func add_experience(amount):
    if(amount <= 0):
        return
    experience += amount
    var mat := level_up_bar.get_active_material(0)

    while(experience >= experience_to_level_up):
        experience -= experience_to_level_up
        level += 1
        experience_to_level_up = base_experience_to_level_up * (level * level)
        payout_label.text = Globals.format_number(get_payout())
        
    mat.set_shader_parameter("progress", experience/experience_to_level_up)
    level_label.text = str(level)

@export var coin_animator: AnimationPlayer

var base_payout = 5000000 #5 million


func get_payout():
    var payout_count = lights.values().count(true) 
    if(payout_count <= 0):
        return 0
    return (base_payout  * pow(2,2*(payout_count-1))) * (level * level)


@export var letter_mesh: MeshInstance3D

var surface_index = {
    "red": 0,
    "orange": 1,
    "yellow": 2,
    "green": 3,
    "blue": 4,
    "indigo": 5,
    "violet": 6
}

var lights = {
    "red": false,
    "orange": false,
    "yellow": false,
    "green": false,
    "blue": false,
    "indigo": false,
    "violet": false
}

func set_light(color: String, is_on: bool) -> void:
    if lights.has(color):
        lights[color] = is_on
        var mat = letter_mesh.get_active_material(surface_index[color]) as StandardMaterial3D
        mat.emission_energy_multiplier = 1.0 if is_on else 0.0
    payout_label.text = Globals.format_number(get_payout())
        
func set_all(is_on) -> void:
    for key in lights.keys():
        lights[key] = is_on
        var mat = letter_mesh.get_active_material(surface_index[key]) as StandardMaterial3D
        mat.emission_energy_multiplier = 1.0 if is_on else 0.0
    payout_label.text = Globals.format_number(get_payout())


#wheel specific callbacks
func red_win():
    set_light("red", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func orange_win():
    set_light("orange", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func yellow_win():
    set_light("yellow", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func green_win():
    set_light("green", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func blue_win():
    set_light("blue", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func indigo_win():
    set_light("indigo", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func violet_win():
    set_light("violet", true)
    wheelSound.stream = winSound
    wheelSound.play()
    
func rainbow_win():
    set_all(true)
    cash_out()


func black_lose():
    set_all(false)
    wheelSound.stream = loseSound
    wheelSound.play()
    pass
    
func cash_out():
    var payout_count = lights.values().count(true) 
    if(payout_count <= 0):
        return
    wheelSound.stream = jackpotSound
    wheelSound.play()
    var payout =  get_payout()#so its 5mil * 2/8/32/128/512/2048/8192 or 1/4/16/64/256/1024/4096
    add_money(payout)
    
    var active_colors = []
    for color in lights.keys():
        if lights[color]:
            active_colors.append(color)
            
    # Start blinking in the background
    for color in active_colors:
        blink_light(color, 6, 0.15) # no await, runs in background

    #particles and stuff
    set_all(false)
    
    
    
func blink_light(color, times, speed) -> Tween:
    var tween = get_tree().create_tween()
    var idx = surface_index[color]
    var mat = letter_mesh.get_active_material(idx) as StandardMaterial3D

    for i in times:
        tween.tween_property(mat, "emission_energy_multiplier", 1.5, speed)
        tween.tween_property(mat, "emission_energy_multiplier", 0.0, speed)

    return tween


    
func _on_luck_button_button_up() -> void:
    want_to_rebuild = true
