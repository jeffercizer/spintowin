extends SpinnerBase
class_name FishingMinigameSpinner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    damping = 0.98
    wheel_angular_velocity = 0.0
    reset()
    pass

@export var music_player: AudioStreamPlayer3D
@export var good_result_sound: AudioStream
@export var best_result_sound: AudioStream
@export var minigame_parent: Node3D
@export var backwall_blocker: CollisionShape3D
@export var spinner_collider: CollisionShape3D

var degrees_of_rotation_for_fish
var fish_strength
var game_running = false

func start_minigame():
    reset()
    game_running = true
    minigame_parent.visible = true
    backwall_blocker.disabled = false
    spinner_collider.disabled = false
    music_player.play()


var max_degrees_for_fish = 36000 #100 rotations
var seconds_between_variance
func reset(): #requires 40 to 80 rotations
    degrees_of_rotation_for_fish  = randi_range(24000, 28800)
    fish_strength = randi_range(50, 100)
    seconds_between_variance = randi_range(1,6)
    seconds_until_variance = seconds_between_variance
    want_spin = false

var seconds_until_variance = 0
var fish_variance = 1.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if(Globals.want_fishing_minigame and not game_running):
        start_minigame()
        Globals.want_fishing_minigame = false
    if(game_running):
        seconds_until_variance -= delta
        if(seconds_until_variance <= 0.0):
            seconds_until_variance = seconds_between_variance
            fish_variance = randf() + 0.5
        if dragging: #we spin the wheel with the mouse
            var torque_multi = clamp(mouse_distance / 200, 0.0, 1.0)
            torque_multi = torque_multi * 8
            var angle = get_mouse_angle()
            if angle != null and last_mouse_angle != null:
                var diff = wrapf(angle - last_mouse_angle, -PI, PI)
                drag_angular_velocity = abs(diff) / delta  # radians/sec
                rotate_y(wheel_angular_velocity * delta)
                wheel_angular_velocity *= damping #natural slow
                wheel_angular_velocity += diff * torque_multi #increase by mouse
            last_mouse_angle = angle   
        elif abs(wheel_angular_velocity) > 0.0001: #we spin the wheel for fun
            rotate_y(wheel_angular_velocity * delta)
            wheel_angular_velocity *= damping
        
        print(str(fish_strength * fish_variance * delta))
        wheel_angular_velocity -= fish_strength * fish_variance * delta
        
        degrees_of_rotation_for_fish -= wheel_angular_velocity
        
        if(degrees_of_rotation_for_fish >= max_degrees_for_fish):
            degrees_of_rotation_for_fish = max_degrees_for_fish
        update_line()
        if(degrees_of_rotation_for_fish <= 0.0):
            #pull fish
            print("FISH")
            wheelSound.play() #victory sound
            tickerSound.stop()
            music_player.stop()
            game_running = false
            minigame_parent.visible = false
            backwall_blocker.disabled = true
            spinner_collider.disabled = true

@export var line_path: Path3D
@export var path_follower: PathFollow3D

func update_line():
    var percent = (degrees_of_rotation_for_fish / max_degrees_for_fish)
    path_follower.progress_ratio = percent
