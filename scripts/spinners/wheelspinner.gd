extends SpinnerBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    base_experience_to_level_up = 20
    experience_to_level_up = base_experience_to_level_up * (level * level)
    machine_curve = {
        "luck_cap": 10,
        "thresholds": [
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
            { "luck": 1,  "extra_spin": 10.0, "flatpositive": 15.0, "bigflatpos": 10.0, "flatnegative": 10.0, "smallflatnegative": 10.0, "2xmulti": 2.0, "4xmulti": 2.0,  "2x_extra_spin": 0.0, "4x_extra_spin": 0.0},
        ]
    }
    #goodness can be used to have certain slices grow faster than their base weight would encourage
    #my idea is so we can make jackpots super super rare but become very doable
    add_slice("extra_spin", winMaterial, 1.0, Callable(self, "extra_spin")) 
    add_slice("flatnegative", loseMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("flatpositive", winMaterial, 1.0, Callable(self, "flat_pos")) 
    add_slice("flatnegative", winMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("bigflatpos", loseMaterial, 1.0, Callable(self, "big_flat_pos"))
    add_slice("flatnegative", winMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("2xmulti", loseMaterial, 1.0, Callable(self, "2x_multi"))
    add_slice("flatnegative", jackpotMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("4xmulti", loseMaterial, 1.0, Callable(self, "4x_multi"))  
    add_slice("smallflatnegative", jackpotMaterial, 1.0, Callable(self, "default_lose")) 
    add_slice("2x_extra_spin", jackpotMaterial, 1.0, Callable(self, "2_spins")) 
    add_slice("smallflatnegative", jackpotMaterial, 1.0, Callable(self, "default_lose"))
    add_slice("4x_extra_spin", jackpotMaterial, 1.0, Callable(self, "4_spins")) 
    add_slice("smallflatnegative", jackpotMaterial, 1.0, Callable(self, "default_lose"))
    super._ready()
    
    
#denominators are 1 2 3 4 5 6 10 12 15 20 30 60 for total weights to fit buckets
@export var winMaterial: ShaderMaterial
@export var loseMaterial: ShaderMaterial
@export var jackpotMaterial: ShaderMaterial

@export var winLabel: Label3D
@export var loseLabel: Label3D
@export var jackpotLabel: Label3D

@export var level_label: Label3D

@export var loseSound: AudioStream
@export var winSound: AudioStream
@export var jackpotSound: AudioStream


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)
    
func _physics_process(_delta: float) -> void:
    super._physics_process(_delta)

func start_spin():
    super.start_spin()
    
func _on_spin_requested() -> void:
    if(want_spin):
        return #we are already spinning
    emit_signal("spin_started")
    start_spin()
    
    
func add_experience(amount):
    if(amount <= 0):
        return
    experience += amount
    var mat := level_up_bar.get_active_material(0)

    while(experience >= experience_to_level_up):
        experience -= experience_to_level_up
        level += 1
        experience_to_level_up = base_experience_to_level_up * (level * level)
        winLabel.text = "= Win " + str(get_win_amount()) + "$"
        jackpotLabel.text = "= Win " + str(get_jackpot_amount()) + "$"
        
    mat.set_shader_parameter("progress", experience/experience_to_level_up)
    level_label.text = str(level)

@export var coin_animator: AnimationPlayer

func get_win_amount():
    return ((20 * pow(Globals.level_effect, level-1)))
    
func get_jackpot_amount():
    return (200 * pow(Globals.level_effect, level-1))
    
#wheel specific callbacks
func default_win():
    var reward = get_win_amount()
    add_money(reward)
    add_experience(reward)
    wheelSound.stream = winSound
    wheelSound.play()

func default_lose():
    wheelSound.stream = loseSound
    wheelSound.play()
    pass
    
func default_jackpot():
    var reward = get_jackpot_amount()
    add_money(reward)
    add_experience(reward)
    coin_animator.play("coinfountain-lvl1")
    wheelSound.stream = jackpotSound
    wheelSound.play()
    
func _on_luck_button_button_up() -> void:
    want_to_rebuild = true
