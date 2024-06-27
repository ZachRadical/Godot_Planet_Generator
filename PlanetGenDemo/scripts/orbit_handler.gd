extends Node3D
var bodies_speed = []


func _ready():
	randomize()
	for i in get_children():
		if !(i is Camera3D) && (i is Node3D):
			bodies_speed.push_back(randf_range(0.01, 0.04))
			var anchor = i
			var body = anchor.get_child(0)
			anchor.rotate_y(deg_to_rad(randf_range(0, 360)))
			body.rotate_y(deg_to_rad(randf_range(0, 360)))




func _process(delta):
	for i in len(get_children()):
		if !(get_child(i) is Camera3D) && (get_child(i) is Node3D):
			var anchor = get_child(i)
			var body = anchor.get_child(0)
			body.rotate_y(bodies_speed[i] * delta)
			anchor.rotate_y((bodies_speed[i]/10) * delta)
		
