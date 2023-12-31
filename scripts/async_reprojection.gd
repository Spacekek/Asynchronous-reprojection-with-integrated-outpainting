extends Node3D

const viewport_distance : float = 10.0

@export var viewport_path : NodePath
@export var projection_path : NodePath
@export var async_camera_path : NodePath
@export var timer_path : NodePath
@export var target_fps : int = 1

@onready var viewport : SubViewport = get_node(viewport_path)
@onready var projection : MeshInstance3D = get_node(projection_path)
@onready var async_camera : Camera3D = get_node(async_camera_path)


func _ready() -> void:
	var timer = get_node(timer_path)
	var frame_duration = 1.0/float(target_fps)
	timer.start(frame_duration)
	
	_resize()
	get_tree().get_root().size_changed.connect(_resize)
	
	var viewport_texture = viewport.get_texture()
	projection.mesh.material.set_shader_parameter("albedo_texture", viewport_texture)


func _on_timer_timeout():
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var normal = async_camera.project_ray_normal(0.5 * viewport.get_visible_rect().size)
	projection.global_position = async_camera.global_position + viewport_distance * normal
	projection.look_at(async_camera.global_position + 2 * viewport_distance * normal)
	
	# save frame as image for debugging
	get_viewport().get_texture().get_image().save_png("/home/kek/test/s.png")


func _process(delta: float) -> void:
	var source_camera = get_node(viewport_path).get_camera_3d()
	async_camera.global_transform = source_camera.global_transform


func _resize() -> void:
	viewport.size = DisplayServer.window_get_size()
	projection.mesh.size.y = 2 * viewport_distance * tan(deg_to_rad(0.5 * async_camera.fov))
	projection.mesh.size.x = projection.mesh.size.y * viewport.size.x / viewport.size.y


func _input(event: InputEvent):
	viewport.push_input(event)
