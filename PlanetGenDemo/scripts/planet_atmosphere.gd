extends MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_lta):
	var vecToSun = global_position.direction_to(Vector3(0,0,0));
	self.get_active_material(0).set_shader_parameter("light_direction", vecToSun);

