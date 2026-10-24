extends BoneAttachment3D

@onready var character = $"../.."

@onready var vfx = $gun/Flash/AnimationPlayer
@onready var sfx = $gun/SFX

func _ready() -> void:
	# TODO: pick the bone ID based on the expected bone name, as our skeleton might have a different bone order
	character.input.action_pressed.connect(action_pressed)

func action_pressed(action):
	if action == "Fire":
		fire()

func fire():
	vfx.play("flash")
	sfx.play()
