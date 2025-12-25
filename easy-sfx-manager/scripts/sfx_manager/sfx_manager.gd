class_name Sfx_Manager extends Node
## [SfxLib] class where Libraries and Presets lies
@export var sfx_library: SfxLib
## Setup max amount of players to be active in playtime
@export var num_audio_players: int = 100

## Queue array of active players
var ap_active: Array = []

#region private sfx manager functions

## Look for preset in [SfxLib.presets] and return its data respectively.
## If preset is taken, amount of preset instances decreased.
func _get_preset(preset_name: StringName) -> Sound_Preset:
	if preset_name not in sfx_library.presets:
		push_error("preset is not found: ", preset_name)
		return

	var sound_preset: Sound_Preset = sfx_library.presets[preset_name]

	if not sound_preset:
		push_error("init a sound library class for preset: ", preset_name)
		return

	if not sound_preset.sound_library:
		push_error("Enter Sound Library name in preset: ", sound_preset)
		return

	if not sound_preset.instances_num >= 1:
		push_warning("No preset instance available yet for: ", sound_preset.sound_library)
		return

	if not sfx_library.libraries.has(sound_preset.sound_library):
		push_error("cannot find library with name: ", sound_preset.sound_library)
		return

	sound_preset.instances_num -= 1
	print("taken sound preset: ", sound_preset.instances_num)
	return sound_preset

## Setup audio parameters to [AudioStreamPlayer] or [AudioStreamPlayer3D]. Modify parameters via SfxLibrary UI
func _set_audio_parameters(audio_player: Object, sound_preset: Sound_Preset) -> void:
	audio_player.bus = sound_preset.bus
	audio_player.playback_type = sound_preset.playback_type
	audio_player.volume_db = linear_to_db(sound_preset.volume)

## Set stream for a player. Setup [member is_random: bool] to use random tracks in Library.
## [br] Setup [member track_index: int] if specific track has to be played (If [member is_random] flag is true, will override it).
## [br] If [SfxArray] has 1 item, play 0 index.
func _set_stream(sfx_manager_player: Object, sound_preset: Sound_Preset, is_random: bool = false, track_index: int = 0) -> void:
	if not _check_sfx_player_null(sfx_manager_player):
		return

	var sfx_libraries: Array[AudioStream] = sfx_library.libraries[str(sound_preset.sound_library)].sounds

	if sfx_libraries.size() == 1:
		sfx_manager_player.stream = sfx_libraries[0]
		return
	if is_random:
		sfx_manager_player.stream = sfx_libraries.pick_random()
	else:
		sfx_manager_player.stream = sfx_libraries[track_index]

## Helper function to check for audio player existance.
func _check_sfx_player_null(sfx_manager_player: Object) -> bool:
	if !sfx_manager_player:
		push_error("sfx_manager_player is null")
		return false
	return true

##	Quickly creates a "oneShot" [AudioStreamPlayer], plays a sound selected from [member sfx_library], then removes audio player from scene tree. [br]
##	Use [member is_3d: bool] parameter to instantiate as [AudioStreamPlayer3D] and setup [member position: Vector3]. [br]
##	Both flags are false and Vec3.ZERO by default respectively
##	Set [member track_index] to select track manually (If [member is_random = true], will override this parameter and will play random track instead.). [member track_index] is 0 index by default.
func _play_sound(preset_name: StringName, position: Vector3 = Vector3.ZERO, track_index: int = 0, is_random: bool = false, is_3d: bool = false) -> void:
	var sound_preset: Sound_Preset = _get_preset(preset_name)
	if not sound_preset:
		return

	var sfx_manager_player: Object

	if is_3d:
		sfx_manager_player = create_audio_player(sound_preset, true, position)
	else:
		sfx_manager_player = create_audio_player(sound_preset)

	if sfx_manager_player == null:
		return

	if is_random:
		_set_stream(sfx_manager_player, sound_preset, true)
	else:
		_set_stream(sfx_manager_player, sound_preset, false, track_index)

	sfx_manager_player.play()
	await sfx_manager_player.finished
	delete_audio_player(sfx_manager_player)

##	Create and return [AudioStreamInteractive]. Use [member is_3d: bool] parameter to instantiate as positional audio player and setup its [member position] parameter according a usecase. [br]
##	Setup track_index to play certain audio track in Library
func _play_multi_sfx(preset_name: StringName, track_index: int = 0, position: Vector3 = Vector3.ZERO, is_3d: bool = false) -> Object:
	var sound_preset: Sound_Preset = _get_preset(preset_name)
	if not sound_preset:
		return null

	var sfx_manager_player: Object

	if is_3d:
		sfx_manager_player = create_audio_player(sound_preset, true, position)
	else:
		sfx_manager_player = create_audio_player(sound_preset)

	if sfx_manager_player == null:
		return null

	_set_stream(sfx_manager_player, sound_preset, track_index)
	sfx_manager_player.play()
	return sfx_manager_player


#region sfx manager queue

## Check for queue availability
func _check_queue_available() -> bool:
	if ap_active.size() >= num_audio_players:
		push_warning("Cannot create another audio_player at the moment. Max audio_players  reached. Free instances or wait for quick audio to finish.") # *debug
		return false
	return true

## Add audio player to queue
func _add_to_queue(sfx_manager_player: Object, sound_preset: Sound_Preset) -> void:
	ap_active.append(sfx_manager_player)
	sfx_manager_player.finished.connect(_on_stream_finish.bind(sound_preset))

## Remove active audio player from queue
func _remove_from_queue() -> void:
	if not ap_active.is_empty():
		ap_active.pop_front()


#region sfx manager signals

## Pop active audio player from array, return preset instance to it's available instances,
func _on_stream_finish(sound_preset: Sound_Preset):
	_remove_from_queue()
	sound_preset.instances_num += 1
	print("Returning audio preset back: %s" %sound_preset.sound_library)


#region sfx manager public functions
## Create and return [AudioStreamPlayer]. If [member is_3d: bool] parameter is set, it will instantiate player as [AudioStreamPlayer3D]. [br]
## Setup [member position: Vector3] for positional player, as it is [Vector3.ZERO)] by default
func create_audio_player(sound_preset: Sound_Preset, is_3d: bool = false, position: Vector3 = Vector3.ZERO) -> Object:
	if !_check_queue_available():
		return null

	var sfx_manager_player: Object

	if is_3d:
		sfx_manager_player = AudioStreamPlayer3D.new()
	else:
		sfx_manager_player = AudioStreamPlayer.new()

	_add_to_queue(sfx_manager_player, sound_preset)

	get_tree().root.add_child(sfx_manager_player)
	_set_audio_parameters(sfx_manager_player, sound_preset)

	if is_3d:
		sfx_manager_player.global_position = position

	return sfx_manager_player

## Remove [AudioStreamPlayer] or [AudioStreamPlayer3D] from scene tree.
func delete_audio_player(sfx_manager_player: Object) -> void:
	if not is_instance_valid(sfx_manager_player):
		push_error("Audio player is null: \"%s\"" %sfx_manager_player)
		return

	_remove_from_queue()

	sfx_manager_player.call_deferred("queue_free")

#region quick sfx manager functions

## play non directional sound
func play_sound(preset_name: StringName, track_index: int = 0) -> void:
	_play_sound(preset_name, Vector3.ZERO, track_index)
## play positional 3d sound
func play_sound_3d(preset_name: StringName, position: Vector3, track_index: int = 0) -> void:
	_play_sound(preset_name, position, track_index, false, true)
## play random sound from library
func play_sound_random(preset_name: StringName) -> void:
	_play_sound(preset_name, Vector3.ZERO, 0, true)
## play positional random sound 3d
func play_sound_3d_random(preset_name: StringName, position: Vector3) -> void:
	_play_sound(preset_name, position, 0, true, true)

## Works for [AudioStreamInteractive]. Creates a [AudioStreamPlayer], play a set of auto advanced clips or a single clip.
func play_multi_sfx(preset_name: StringName, track_index: int = 0) -> AudioStreamPlayer:
	return _play_multi_sfx(preset_name, track_index)
## Works for [AudioStreamInteractive]. Creates a [AudioStreamPlayer3D], play a set of auto advanced clips or a single clip.
func play_multi_sfx_3d(preset_name: StringName, position: Vector3, track_index: int = 0) -> AudioStreamPlayer3D:
	return _play_multi_sfx(preset_name, track_index, position, true)


## Use if [AudioStreamInteractive] clip needs to get out of loop or manually switched.
func switch_multi_sfx_clip(sfx_manager_player: Object, clip_index: int) -> void:
	if not sfx_manager_player:
		push_error("can't switch clip because sfx_manager_player is null")
		return

	var pb: AudioStreamPlayback = sfx_manager_player.get_stream_playback()
	pb.switch_to_clip(clip_index)

## Use if need to switch [AudioStreamInteractive] tracks.
func switch_multi_sfx_track(sfx_manager_player: Object, preset_name: StringName, track_index: int = 0) -> void:
	var sound_preset: Sound_Preset = _get_preset(preset_name)
	if sfx_manager_player.playing:
		sfx_manager_player.stop()
	_set_stream(sfx_manager_player, sound_preset, track_index)
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
