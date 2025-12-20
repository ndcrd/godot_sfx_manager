class_name Sfx_Manager extends Node
@export var sfx_library: SfxLib


#region private sfx manager functions

## Look for preset in [SfxLib.presets] and return its data respectively.
func _get_preset(preset_name: StringName) -> Sound_Lib:
	if preset_name not in sfx_library.presets:
		push_error("preset is not found: ", preset_name)
		return

	var sound_lib: Sound_Lib = sfx_library.presets[preset_name]

	if not sound_lib:
		push_error("init a sound library for: ", preset_name, " preset")
		return

	if sound_lib.library_name.is_empty():
		push_error("enter a sound library name")
		return

	if not sfx_library.libraries.has(sound_lib.library_name):
		push_error("cannot find library with name: ", sound_lib.library_name)
		return

	return sound_lib

## Setup audio parameters to [AudioStreamPlayer] or [AudioStreamPlayer3D]. Modify parameters via SfxLibrary UI
func _set_audio_parameters(audio_player: Object, sound_lib: Sound_Lib) -> void:
	audio_player.bus = sound_lib.bus
	audio_player.playback_type = sound_lib.playback_type
	audio_player.volume_db = linear_to_db(sound_lib.volume)

## Set stream for a player, If [SfxArray] has 1 item, play 0 index, set [member track_index] to play [AudioStream] manually.
func _set_stream(sfx_manager_player: Object, sound_lib: Sound_Lib, track_index: int = 0) -> void:
	var sfx_libraries: Array[AudioStream] = sfx_library.libraries[str(sound_lib.library_name)].sounds

	if sfx_libraries.size() == 1:
		sfx_manager_player.stream = sfx_libraries[0]
		return
	sfx_manager_player.stream = sfx_libraries[track_index]

## Set random stream for a player, If [SfxArray] has 1 item, play 0 index.
func _set_stream_random(sfx_manager_player: Object, sound_lib: Sound_Lib) -> void:
	var sfx_libraries: Array[AudioStream] = sfx_library.libraries[str(sound_lib.library_name)].sounds

	if sfx_libraries.size() == 1:
		sfx_manager_player.stream = sfx_libraries[0]
		push_warning("There is a single sfx in a library. Consider using _set_stream() function")
		return
	sfx_manager_player.stream = sfx_libraries.pick_random()

#region sfx manager public functions
## Create [AudioStreamPlayer] and with audio parameters preset. You can configure parameters in Presets SfxLibrary UI
func create_audio_player(sound_lib: Sound_Lib) -> AudioStreamPlayer:
	var sfx_manager_player = AudioStreamPlayer.new()

	get_tree().root.add_child(sfx_manager_player)
	_set_audio_parameters(sfx_manager_player, sound_lib)

	return sfx_manager_player

## Create [AudioStreamPlayer3D] and with audio parameters preset. You can configure parameters in Presets SfxLibrary UI
func create_audio_player_3d(sound_lib: Sound_Lib, position: Vector3) -> AudioStreamPlayer3D:
	var sfx_manager_player_3d = AudioStreamPlayer3D.new()

	get_tree().root.add_child(sfx_manager_player_3d)
	_set_audio_parameters(sfx_manager_player_3d, sound_lib)

	sfx_manager_player_3d.global_position = position

	return sfx_manager_player_3d

## Remove [AudioStreamPlayer] or [AudioStreamPlayer3D] from scene tree.
func delete_audio_player(sfx_manager_player: Object) -> void:
	if not is_instance_valid(sfx_manager_player):
		push_error("Audio player is null: \"%s\"" %sfx_manager_player)
		return
	sfx_manager_player.call_deferred("queue_free")

#region quick sfx manager functions

## Quickly creates a "oneShot" Indirectional [AudioStreamPlayer], plays a sound selected from [member sfx_library], then removes audio player from scene tree. [br]
## Set [member track_index] to select track manually. [member track_index] is 0 by default
func play_sound(sound_name: StringName, track_index: int = 0) -> void:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib:
		push_error("init a sound library for: ", sound_name, " preset")
		return

	var sfx_manager_player: AudioStreamPlayer = create_audio_player(sound_lib)

	_set_stream(sfx_manager_player, sound_lib, track_index)

	sfx_manager_player.play()

	await sfx_manager_player.finished
	delete_audio_player(sfx_manager_player)

## Quickly creates a "oneShot" Positional [AudioStreamPlayer3D], plays a sound selected from [member sfx_library], then removes audio player from scene tree. [br]
## Set [member track_index] to select track manually. [member track_index] is 0 by default
func play_sound_3d(sound_name: StringName, position: Vector3, track_index: int = 0) -> void:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib:
		push_error("init a sound library for: ", sound_name, " preset")
		return

	var sfx_manager_player_3d: AudioStreamPlayer3D = create_audio_player_3d(sound_lib, position)
	_set_stream(sfx_manager_player_3d, sound_lib, track_index)
	sfx_manager_player_3d.play()

	await sfx_manager_player_3d.finished
	delete_audio_player(sfx_manager_player_3d)

## Quickly creates a "oneShot" Indirectional [AudioStreamPlayer], plays a random sound selected from [member sfx_library], then removes audio player from scene tree. [br]
func play_sound_random(sound_name: StringName) -> void:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib:
		push_error("init a sound library for: ", sound_name, " preset")
		return


	var sfx_manager_player: AudioStreamPlayer = create_audio_player(sound_lib)

	_set_stream_random(sfx_manager_player, sound_lib)

	sfx_manager_player.play()

	await sfx_manager_player.finished
	delete_audio_player(sfx_manager_player)

## Quickly creates a "oneShot" Positional [AudioStreamPlayer3D], plays a random sound selected from [member sfx_library], then removes audio player from scene tree. [br]
func play_sound_3d_random(sound_name: StringName, position: Vector3) -> void:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib:
		push_error("init a sound library for: ", sound_name, " preset")
		return


	var sfx_manager_player_3d: AudioStreamPlayer3D = create_audio_player_3d(sound_lib, position)
	_set_stream_random(sfx_manager_player_3d, sound_lib)
	sfx_manager_player_3d.play()

	await sfx_manager_player_3d.finished
	delete_audio_player(sfx_manager_player_3d)

## Works for [AudioStreamInteractive]. Creates a [AudioStreamPlayer], play a set of auto advanced clips or a single clip.
func play_multi_sfx(sound_name: StringName, track_index: int = 0) -> AudioStreamPlayer:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib:
		push_error("init a sound library for: ", sound_name, " preset")
		return

	var sfx_manager_player: AudioStreamPlayer = create_audio_player(sound_lib)

	_set_stream(sfx_manager_player, sound_lib, track_index)
	sfx_manager_player.play()

	return sfx_manager_player

## Works for [AudioStreamInteractive]. Creates a [AudioStreamPlayer3D], play a set of auto advanced clips or a single clip.
func play_multi_sfx_3d(sound_name: StringName, position: Vector3, track_index: int = 0) -> AudioStreamPlayer3D:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if not sound_lib:
		push_error("init a sound library for: ", sound_name, " preset")
		return

	var sfx_manager_player: AudioStreamPlayer3D = create_audio_player_3d(sound_lib, position)

	_set_stream(sfx_manager_player, sound_lib, track_index)
	sfx_manager_player.play()

	return sfx_manager_player

## Use if [AudioStreamInteractive] clip needs to get out of loop or manually switched.
func switch_multi_sfx_clip(sfx_manager_player: Object, clip_index: int) -> void:
	if not sfx_manager_player:
		push_error("can't switch clip because sfx_manager_player is null")
		return

	var pb: AudioStreamPlayback = sfx_manager_player.get_stream_playback()
	pb.switch_to_clip(clip_index)

## Use if need to switch [AudioStreamInteractive] tracks.
func switch_multi_sfx_track(sfx_manager_player: Object, sound_name: StringName, track_index: int = 0) -> void:
	var sound_lib: Sound_Lib = _get_preset(sound_name)
	if sfx_manager_player.playing:
		sfx_manager_player.stop()
	_set_stream(sfx_manager_player, sound_lib, track_index)
	sfx_manager_player.play()

## Stop playing [AudioStreamInteractive] stream and removes player from scene tree.
## @experimental This method currently needs an index of final clip of [AudioStreamInteractive] to measure it's length and emit [signal AudioStreamPlayer.finished]. It might be changed for better in future.
func stop_multi_sfx(sfx_manager_player: Object, last_clip_idx: int) -> void:
	if not is_instance_valid(sfx_manager_player):
		push_error("sfx_manager_player is null")
		return
	var stream_player = sfx_manager_player
	var clip = stream_player.stream.get_clip_stream(last_clip_idx)
	var clip_length = clip.get_length()

	await get_tree().create_timer(clip_length).timeout

	if not is_instance_valid(stream_player):
		push_warning("Trying to reach already freed instance. Returning")
		return

	var pb: AudioStreamPlayback = stream_player.get_stream_playback()
	if pb == null:
		delete_audio_player(stream_player)
		return
	pb.stop()

	await stream_player.finished
	delete_audio_player(stream_player)
