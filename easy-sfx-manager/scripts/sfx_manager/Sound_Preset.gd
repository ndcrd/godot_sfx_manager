class_name Sound_Preset extends Resource

@export_category("Set sound effect")
##Insert a sound library name from [SfxLibrary] > Libraries > Library name
@export var sound_library: StringName


@export_category("Set sound parameters")

##Preset volume. Linear. Will set overall [AudioPlayer] volume
@export var volume: float = 0.5

##[AudioPlayer] pitch paramter.
@export var pitch: float = 0.0

##Send [AudioPlayer] to a Audio Bus by name.
@export var bus: StringName = "master"

##Setup playback type for [AudioPlayer]
@export var playback_type := AudioServer.PLAYBACK_TYPE_DEFAULT

##Max amount of same preset instances can be played.
##Decreases amount of same preset instances played in short amount of time.
@export var instances_num: int = 100