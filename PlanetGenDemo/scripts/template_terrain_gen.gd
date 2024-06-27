@tool
extends MeshInstance3D
var mdt = MeshDataTool.new()

############ PARAM LIST #################
@export_range (1, 5) var height_multiplier : float = 3 : set = set_height_multiplier
@export_range(0.1, 1.0) var ocean_floor_smoothing : float = 0.3 : set = set_ocean_floor_smoothing
@export_range (-0.5, 0.5) var ridge_elevation : float = 0.2 : set = set_ridge_elevation
@export_range (0.0, 10.0) var ocean_depth : float = 0.2 : set = set_ocean_depth
@export_range (0.0, 10.0) var ocean_depth_multiplier : float = 1.5 : set = set_ocean_depth_multiplier
@export_range (0.0, 5.0) var mountain_blend : float = 1.0 : set = set_mountain_blend

############ Defines the formation of continents ###################
@export_category("Shape Noise")
@export var fnl = FastNoiseLite.new()
@export var new_seed : bool = false : set = get_new_seed
@export var frequency : float = fnl.frequency : set = set_frequency
@export_subgroup("Fractals")
@export var fractal_lacunarity : float = fnl.fractal_lacunarity : set = set_fractal_lacunarity
@export var fractal_gain : float = fnl.fractal_gain : set = set_fractal_gain
@export var weight_strength : float = fnl.fractal_weighted_strength : set = set_strength
@export_range(1,10) var fractal_octaves : int = fnl.fractal_octaves : set = set_fractal_octaves
@export_subgroup("Domain Warp")
@export var domain_warp_enabled : bool = fnl.domain_warp_enabled : set = toggle_domain_warp
@export var domain_warp_amplitude : float = fnl.domain_warp_amplitude : set = set_domain_warp_amplitude
@export var domain_warp_frequency : float = fnl.domain_warp_frequency : set = set_domain_warp_frequency
@export var domain_warp_fractal_lacunarity : float = fnl.domain_warp_fractal_lacunarity : set = set_domain_fractal_lacunarity
@export var domain_warp_fractal_gain : float = fnl.domain_warp_fractal_gain : set = set_domain_warp_fractal_gain
@export_range(1,10) var domain_warp_fractal_octaves : int = fnl.domain_warp_fractal_octaves : set = set_domain_warp_fractal_octaves

############ Defines the shape of the elevated terrain ###################
@export_category("Mountain Noise")
@export var fnl2 = FastNoiseLite.new()
@export var new_seed2 : bool = false : set = get_new_seed2
@export var frequency2 : float = fnl2.frequency : set = set_frequency2
@export_subgroup("Fractals2")
@export var fractal_lacunarity2 : float = fnl2.fractal_lacunarity : set = set_fractal_lacunarity2
@export var fractal_gain2 : float = fnl2.fractal_gain : set = set_fractal_gain2
@export var weight_strength2 : float = fnl2.fractal_weighted_strength : set = set_strength2
@export_range(1,10) var fractal_octaves2 : int = fnl2.fractal_octaves : set = set_fractal_octaves2
@export_subgroup("Domain Warp2")
@export var domain_warp_enabled2 : bool = fnl2.domain_warp_enabled : set = toggle_domain_warp2
@export var domain_warp_amplitude2 : float = fnl2.domain_warp_amplitude : set = set_domain_warp_amplitude2
@export var domain_warp_frequency2 : float = fnl2.domain_warp_frequency : set = set_domain_warp_frequency2
@export var domain_warp_fractal_lacunarity2 : float = fnl2.domain_warp_fractal_lacunarity : set = set_domain_fractal_lacunarity2
@export var domain_warp_fractal_gain2 : float = fnl2.domain_warp_fractal_gain : set = set_domain_warp_fractal_gain2
@export_range(1,10) var domain_warp_fractal_octaves2 : int = fnl2.domain_warp_fractal_octaves : set = set_domain_warp_fractal_octaves2

########### Defines the location of elevated terrain ####################
@export_category("Mask Noise")
@export var fnl3 = FastNoiseLite.new()
@export var new_seed3 : bool = false : set = get_new_seed3
@export var frequency3 : float = fnl3.frequency : set = set_frequency3
@export_subgroup("Fractals3")
@export var fractal_lacunarity3 : float = fnl3.fractal_lacunarity : set = set_fractal_lacunarity3
@export var fractal_gain3 : float = fnl3.fractal_gain : set = set_fractal_gain3
@export var weight_strength3 : float = fnl3.fractal_weighted_strength : set = set_strength3
@export_range(1,10) var fractal_octaves3 : int = fnl3.fractal_octaves : set = set_fractal_octaves3
@export_subgroup("Domain Warp3")
@export var domain_warp_enabled3 : bool = fnl3.domain_warp_enabled : set = toggle_domain_warp3
@export var domain_warp_amplitude3 : float = fnl3.domain_warp_amplitude : set = set_domain_warp_amplitude3
@export var domain_warp_frequency3 : float = fnl3.domain_warp_frequency : set = set_domain_warp_frequency3
@export var domain_warp_fractal_lacunarity3 : float = fnl3.domain_warp_fractal_lacunarity : set = set_domain_fractal_lacunarity3
@export var domain_warp_fractal_gain3 : float = fnl3.domain_warp_fractal_gain : set = set_domain_warp_fractal_gain3
@export_range(1,10) var domain_warp_fractal_octaves3 : int = fnl3.domain_warp_fractal_octaves : set = set_domain_warp_fractal_octaves3

var time1
var time2
var time3
var time4
var time5
var time6



# Gets the vec3s of the mesh and deforms them according to noise params
func _ready():

	time1 = Time.get_unix_time_from_system()
	mdt.create_from_surface(self.mesh, 0)
	var vertices:PackedVector3Array = [] 
	
	
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i).normalized()
		var noise = fnl.get_noise_3dv(vertex * fnl.fractal_octaves * fnl.frequency)

		var vert_floor = -ocean_depth + noise * 0.15
		noise = smoothMax(noise, vert_floor, ocean_floor_smoothing)
		if noise < 0.0:
			noise *= 1 + ocean_depth_multiplier

		var mask = fnl3.get_noise_3dv(vertex)
		var mountain_mask = Blend(0, mountain_blend, mask)
		var ridgenoise = fnl2.get_noise_3dv(vertex * fnl2.frequency * fnl2.fractal_octaves) * mountain_mask
		var final_height = 1 + (noise + ridgenoise) * 0.1 #* height_multiplier
		mdt.set_vertex(i, vertex*final_height)
	time2 = Time.get_unix_time_from_system()
	print("Deformations: %s" % (time2 - time1))
	
	
	# Calculate vertex normals, face-by-face.
	
	time3 = Time.get_unix_time_from_system()
	for i in range(mdt.get_face_count()):
		
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		
		# Get vertex position using vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		
		# Calculate face normal.
		var n = (bp - cp).cross(ap - bp).normalized()
		
		# Add face normal to current vertex normal.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))
	time4 = Time.get_unix_time_from_system()
	print("Verts/Normals: %s" % (time4 - time3))
	
	
	# Run through vertices one last time to normalize normals and
	# set color to normal.
	time5 = Time.get_unix_time_from_system()
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex_normal(i)#.normalized()
		mdt.set_vertex_normal(i, v)
		mdt.set_vertex_color(i, Color(v.x, v.y, v.z))
		vertices.append(mdt.get_vertex(i))
	time6 = Time.get_unix_time_from_system()
	print("Normalize/Color: %s" % (time6-time5))
	print("Total load time: %s" % (time6-time1))

	print("Number of vertices in %s: %s" % [get_parent_node_3d(), mdt.get_vertex_count()])
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	var col_node:Node3D = CollisionShape3D.new()
	col_node.shape = mesh.create_trimesh_shape()
	col_node.transform = col_node.transform.scaled(self.basis.get_scale())
	add_sibling.call_deferred(col_node)


	
func smoothMax(a, b, k):
	k = min(0.0, -k);
	var h = max(0.0, min(1.0, (b - a + k) / (2.0 * k)))
	return a * h + b * (1.0 - h) - k * h * (1.0 - h)
	
func Blend(startHeight, blendDst, height):
	return smoothstep(startHeight - blendDst / 2.0, startHeight + blendDst / 2.0, height);


func on_body_data_changed():
	if Engine.is_editor_hint() == true:
		_ready()

func set_height_multiplier(value):
	height_multiplier = value
	on_body_data_changed()

func set_ocean_floor_smoothing(value):
	ocean_floor_smoothing = value
	on_body_data_changed()

func set_ridge_elevation(value):
	ridge_elevation = value
	on_body_data_changed()

func set_ocean_depth(value):
	ocean_depth = value
	on_body_data_changed()

func set_ocean_depth_multiplier(value):
	ocean_depth_multiplier = value
	on_body_data_changed()

func set_mountain_blend(value):
	mountain_blend = value
	on_body_data_changed()
	
func set_frequency(value):
	fnl.frequency = value
	frequency = value
	on_body_data_changed()
	
func set_fractal_lacunarity(value):
	fnl.fractal_lacunarity = value
	fractal_lacunarity = value
	on_body_data_changed()
	
func set_fractal_gain(value):
	fnl.fractal_gain = value
	fractal_gain = value
	on_body_data_changed()

func set_fractal_octaves(value):
	fnl.fractal_octaves = value
	fractal_octaves = value
	on_body_data_changed()
	
func set_strength(value):
	fnl.fractal_weighted_strength = value
	weight_strength = value
	on_body_data_changed()
	
func toggle_domain_warp(value: bool):
	fnl.domain_warp_enabled = value
	domain_warp_enabled = value
	on_body_data_changed()
	
func get_new_seed(_value: bool):
	randomize()
	fnl.seed = randi()
	new_seed = true
	on_body_data_changed()
	
func set_domain_warp_amplitude(value):
	fnl.domain_warp_amplitude = value
	domain_warp_amplitude = value
	on_body_data_changed()

func set_domain_fractal_lacunarity(value):
	fnl.domain_warp_fractal_lacunarity = value
	domain_warp_fractal_lacunarity = value
	on_body_data_changed()
	
func set_domain_warp_fractal_gain(value):
	fnl.domain_warp_fractal_gain = value
	domain_warp_fractal_gain = value
	on_body_data_changed()
	
func set_domain_warp_frequency(value):
	fnl.domain_warp_frequency = value
	domain_warp_frequency = value
	on_body_data_changed()

func set_domain_warp_fractal_octaves(value):
	fnl.domain_warp_fractal_octaves = value
	domain_warp_fractal_octaves = value
	on_body_data_changed()
	
########################
########################

func set_frequency2(value):
	fnl2.frequency = value
	frequency2 = value
	on_body_data_changed()
	
func set_fractal_lacunarity2(value):
	fnl2.fractal_lacunarity = value
	fractal_lacunarity2 = value
	on_body_data_changed()
	
func set_fractal_gain2(value):
	fnl2.fractal_gain = value
	fractal_gain2 = value
	on_body_data_changed()

func set_fractal_octaves2(value):
	fnl2.fractal_octaves = value
	fractal_octaves2 = value
	on_body_data_changed()
	
func set_strength2(value):
	fnl2.fractal_weighted_strength = value
	weight_strength2 = value
	on_body_data_changed()
	
func toggle_domain_warp2(value: bool):
	fnl2.domain_warp_enabled = value
	domain_warp_enabled2 = value
	on_body_data_changed()
	
func get_new_seed2(_value: bool):
	randomize()
	fnl2.seed = randi()
	new_seed2 = true
	on_body_data_changed()
	
func set_domain_warp_amplitude2(value):
	fnl2.domain_warp_amplitude = value
	domain_warp_amplitude2 = value
	on_body_data_changed()

func set_domain_fractal_lacunarity2(value):
	fnl2.domain_warp_fractal_lacunarity = value
	domain_warp_fractal_lacunarity2 = value
	on_body_data_changed()
	
func set_domain_warp_fractal_gain2(value):
	fnl2.domain_warp_fractal_gain = value
	domain_warp_fractal_gain2 = value
	on_body_data_changed()
	
func set_domain_warp_frequency2(value):
	fnl2.domain_warp_frequency = value
	domain_warp_frequency2 = value
	on_body_data_changed()

func set_domain_warp_fractal_octaves2(value):
	fnl2.domain_warp_fractal_octaves = value
	domain_warp_fractal_octaves2 = value
	on_body_data_changed()

########################
########################

func set_frequency3(value):
	fnl3.frequency = value
	frequency3 = value
	on_body_data_changed()
	
func set_fractal_lacunarity3(value):
	fnl3.fractal_lacunarity = value
	fractal_lacunarity3 = value
	on_body_data_changed()
	
func set_fractal_gain3(value):
	fnl3.fractal_gain = value
	fractal_gain3 = value
	on_body_data_changed()

func set_fractal_octaves3(value):
	fnl3.fractal_octaves = value
	fractal_octaves3 = value
	on_body_data_changed()
	
func set_strength3(value):
	fnl3.fractal_weighted_strength = value
	weight_strength3 = value
	on_body_data_changed()
	
func toggle_domain_warp3(value: bool):
	fnl3.domain_warp_enabled = value
	domain_warp_enabled3 = value
	on_body_data_changed()
	
func get_new_seed3(_value: bool):
	randomize()
	fnl3.seed = randi()
	new_seed3 = true
	on_body_data_changed()
	
func set_domain_warp_amplitude3(value):
	fnl3.domain_warp_amplitude = value
	domain_warp_amplitude3 = value
	on_body_data_changed()

func set_domain_fractal_lacunarity3(value):
	fnl3.domain_warp_fractal_lacunarity = value
	domain_warp_fractal_lacunarity3 = value
	on_body_data_changed()
	
func set_domain_warp_fractal_gain3(value):
	fnl3.domain_warp_fractal_gain = value
	domain_warp_fractal_gain3 = value
	on_body_data_changed()
	
func set_domain_warp_frequency3(value):
	fnl3.domain_warp_frequency = value
	domain_warp_frequency3 = value
	on_body_data_changed()

func set_domain_warp_fractal_octaves3(value):
	fnl3.domain_warp_fractal_octaves = value
	domain_warp_fractal_octaves3 = value
	on_body_data_changed()
