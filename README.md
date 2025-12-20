
<img width="1280" height="720" alt="Untitled" src="https://github.com/user-attachments/assets/5591f570-edc8-4143-8dcc-b1b5153815a2" />

# Easy SFX Manager for Godot Engine 4.x.
This is a manager for utilizing positional and non-positional audio in 3D projects. Written in GdScript and planned to be updated with time as C++ GdExtension.
Current iteration is a very basic, robust solution to use as Singleton or as a scene Node based on user scenario.

## Features
  - Audio Players:
    *  3D Audio
    *  Non-positional audio
    *  Positional and Non-positional player management
  - Sound collections:
    *  Audio Libraries
    *  SFX Presets
  - SFX:
    *  One Shot play
    *  Multi Stage SFX
    *  Quick sfx functions (play 3d audio, play random audio, etc.)

## Planned
  *  Persistent audio (such as: bg music, looping sfx, ambient sounds)
  *  Better audio  management (Bus and Bus fx management, ​ signals)  

## How to start
  ### Create manager scene:
  We need to create a sfx_manager scene, so it could be used in our game.
  Create Node scene and attach `sfx_manager.gd` to the Scene Root node.

  <p align="center">
    <img width="1264" height="696" alt="image" src="https://github.com/user-attachments/assets/3a3ccfc8-b175-4b70-9c8f-cf0645538f8c" />
  </p>
  
  ### Use `sfx_manager.tscn` as:
  * Scene Node:
    - Add `sfx_manager.tscn` to a scene tree.
  * Singleton:
    - Go to `Project settings > Globals > click folder icon (set path) > +Add`

  
## Manage sound libraries and presets:
  
  `SfxManager` based on `Libraries` and `Presets` dictionaries.
  
  <p align="center">
    <img width="420" height="720" alt="image" src="https://github.com/user-attachments/assets/5988e000-641a-42af-8c0c-1373e9a2cccf" />
  </p>
  
  `Libraries` section is a dictionary of sound packs. Where `Libraries Dictionary<StringName, SfxArray>` each library keeps an array of `AudioStream` files. Think of that as collection of named folders with audio files inside.
  Presets `Dictionary<StringName, Sound_Lib>` is preset of AudioPlayer parameters for Sound Libraries to be used in `AudioStreamPlayers`.

  Call preset whatever you want, but `Library Name` name should match the name of `Sound Library` for it to access audio data.


  > [!NOTE]
  > You can drag and drop audio files into SFX Array.\
  > 
  > You can save and load SFX Library, SFX Array or Sound_Lib resources.\
  > 
  > You can edit set resource data by right click > edit, but you can't edit set dictionary keys. So you might want to recreate Key/Value Pair correctly.\
  > 
  > *Don't forget to click Add Key/Value Pair when adding new data to dictionary.  Sfx_sfx_managerManager\


  ### Presets parameters:
  For Auido Presets, it's possible to set playback parameters based on your scenario, move audioplayer to specific bus or set a playback type.
  
  * `Library Name <StringName>` - name of sound library to seek audio from
  * `Volume <float>` - playback volume of audioplayer
  * `Pitch <float>` - pitch of audioplayer
  * `Bus <StringName>` - set a bus to be used for audioplayer
  * `Playback Type <PlaybackType>` - set a playback type for audioplayer

  

## Examples
  ### Acess manager as Singleton and play indirect audio:
  
  ```
    func _input(event: InputEvent) -> void:
    if not event is InputEventKey:
      return
    if event.keycode == KEY_F1:
      SfxManager.play_sound(<your_sound: StringName>)
  ```

  ### Access manager as scene node and play 3D audio:
  
  ```
    @export var sfx_manager: Sfx_Manager #set node pass or export var and assign node to it

    func _input(event: InputEvent) -> void:
    if not event is InputEventKey:
      return
    if event.keycode == KEY_F1:
      sfx_manager.play_sound_3d(<your_sound: StringName>, <position: Vector3>)
  ```

  
