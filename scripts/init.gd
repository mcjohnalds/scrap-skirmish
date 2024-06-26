class_name Init
extends Node

@onready var container: Node = $Container
@onready var progress_label: Label = %ProgressLabel
@onready var file_label: Label = %FileLabel


func _ready() -> void:
	var file_names := DirAccess.get_files_at("res://scenes")
	for i in file_names.size():
		var file_name := file_names[i].rstrip(".remap")
		# Files in the exported package hava .remap suffix
		var file_path := "res://scenes/%s" % file_name
		var current_file_path := get_tree().current_scene.scene_file_path
		# Don't want to put a duplicate of this scene into the current tree
		# because the canvas layers would clash. Don't want to add the autoload
		# scene because it autoplays music.
		if file_path == current_file_path or file_path == "res://scenes/autoload.tscn":
			continue

		var percent := floori(float(i) / float(file_names.size()) * 100.0)
		progress_label.text = "Loading assets (%s%%)" % percent
		file_label.text = file_name
		await get_tree().process_frame

		var scene := load(file_path)
		var node: Node = scene.instantiate()
		node.set_script(null)
		for child: Node in Global.get_all_children(node, true):
			child.set_script(null)
			if child is GPUParticles3D:
				child.one_shot = true
				child.emitting = true
		container.add_child(node)
		await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/main.tscn")
