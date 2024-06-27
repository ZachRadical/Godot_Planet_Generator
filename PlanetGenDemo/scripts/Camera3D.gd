extends Camera3D

#lerp_speed is the time in seconds for the camera to realign after player movement
#lower values = lazier camera
#higher values = more precise camera
@export var lerp_speed = 10.0
@export var target_path: NodePath
@export var offset = Vector3(0,0,0)

var target = null

func _ready():
	if target_path:
		target = get_node(target_path)
		self.transform.origin = target.transform.origin
		
func _physics_process(delta):
	if !target:
		return
	var target_pos = target.global_transform.translated_local(offset).origin
	
	global_transform.origin = global_transform.origin.lerp(target_pos, lerp_speed * delta)
	var new_basis = global_transform.looking_at(target.global_transform.origin, target.transform.basis.y)

	global_transform = global_transform.interpolate_with(new_basis, lerp_speed * delta)

		
	#KEEP THIS HANDY FOR RAIL SHOOTER SEGMENTS
	#new_basis.basis.y += Vector3(0,10,0)
	#await get_tree().create_timer(0.1).timeout
