class_name Sound_Lib extends Resource

@export_category("Set sound effect")
@export var library_name: StringName
@export_category("Set sound parameters")
@export var volume: float = 0.5
@export var pitch: float = 0.0
@export var bus: StringName = "master"
@export var playback_type := AudioServer.PLAYBACK_TYPE_DEFAULT