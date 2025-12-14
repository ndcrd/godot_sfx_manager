class_name Sfx_Manager extends Node
@export var sfx_library: SfxLib
#region private sfx manager functions
func _get_preset(preset_name: StringName) -> Sound_Lib:
	if preset_name not in sfx_library.presets:
		push_error("preset is not found: ", preset_name)
		return

	var sound_lib: Sound_Lib = sfx_library.presets[preset_name]

	if sound_lib == null:
		push_error("init a sound library for: ", preset_name, " preset")
		return

	if sound_lib.library_name.is_empty():
		push_error("enter a sound library name")
		return

	if not sfx_library.libraries.has(sound_lib.library_name):
		push_error("cannot find library with name: ", sound_lib.library_name)
		return

	return sound_lib

func _set_audio_parameters(audio_player: Object, sound_lib: Sound_Lib) -> void:
	audio_player.bus = sound_lib.bus
	audio_player.playback_type = sound_lib.playback_type
	audio_player.volume_db = linear_to_db(sound_lib.volume)

#? Shall I move create \ delete players to public?
func _create_audio_player(sound_lib: Sound_Lib) -> AudioStreamPlayer:
	var sfx_manager_player = AudioStreamPlayer.new()
	sfx_manager_player.stream = sfx_library.libraries[str(sound_lib.library_name)].sounds.pick_random()

	get_tree().root.add_child(sfx_manager_player)
	_set_audio_parameters(sfx_manager_player, sound_lib)
	return sfx_manager_player
	#*maybe emit signal*

func _create_audio_player_3d(sound_lib: Sound_Lib, position: Vector3) -> AudioStreamPlayer3D:
	var sfx_manager_player_3d = AudioStreamPlayer3D.new()

	sfx_manager_player_3d.stream = sfx_library.libraries[str(sound_lib.library_name)].sounds.pick_random()

	get_tree().root.add_child(sfx_manager_player_3d)
	_set_audio_parameters(sfx_manager_player_3d, sound_lib)
	sfx_manager_player_3d.global_position = position
	return sfx_manager_player_3d
	#*maybe emit signal*

func _delete_audio_player(sfx_manager_player: Object):
	sfx_manager_player.queue_free()
	#*maybe emit signal*


#region public sfx manager functions
func play_sound(sound_name: StringName):
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib: return

	var sfx_manager_player: AudioStreamPlayer = _create_audio_player(sound_lib)
	sfx_manager_player.play()

	await sfx_manager_player.finished
	_delete_audio_player(sfx_manager_player)

func play_sound_3d(sound_name: StringName, position: Vector3):
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib: return

	var sfx_manager_player_3d: AudioStreamPlayer3D = _create_audio_player_3d(sound_lib, position)
	sfx_manager_player_3d.play()

	await sfx_manager_player_3d.finished
	_delete_audio_player(sfx_manager_player_3d)
