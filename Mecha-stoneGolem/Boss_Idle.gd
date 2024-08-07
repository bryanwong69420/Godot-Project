extends State

@onready var collision = $"../../PlayerDetection/CollisionShape2D"
@onready var progress_bar = owner.find_child("ProgressBar")
# Called when the node enters the scene tree for the first time.

func _ready():
	collision.connect("body_entered", Callable(self, "_on_player_detection_body_entered"))

var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)
		progress_bar.set_deferred("visible",value)
 
func transition():
	if player_entered:
		get_parent().change_state("Boss_Follow")
		print("hui")

 
func _on_player_detection_body_entered(_body):
	player_entered = true
	print(player_entered)
	

