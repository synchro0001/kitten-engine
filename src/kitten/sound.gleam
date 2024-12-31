//// This module defines functions for working with sound effects. Kitten supports two sound systems:
//// - [ZzFX](https://github.com/KilledByAPixel/ZzFX) + [ZzFXM](https://github.com/keithclark/ZzFXM) 
//// by Frank Force and Keith Clark
//// - the usual Web Audio API (so far only tested with .mp3's, but other files should work too)
//// 
//// Once the sounds have been loaded into the engine, you can usee the same functions
//// to initiate, play and stop them, regardless of original format.
//// 
//// To load sounds into the engine, you will need to specify paths to the files containing them
//// (relative to your index.html) as strings in the `sound_sources` list when starting the engine.
//// ZzFX(M) sounds must be stored as `.js` files; I highly recommend that you use their websites
//// ([ZzFX](https://killedbyapixel.github.io/ZzFX/), [ZzFXM](https://keithclark.github.io/ZzFXM/))
//// to create the sounds and then copy the JavaScript output.
//// 
//// To use the sounds in your game, use the `new` function in this module, passing the index
//// of the desired sound file in the `sound_sources` list as the argument. The function is 
//// fallible and will only work if the sound file exists and was correct (although I am still 
//// figuring out the details). For this reason, you should only use it in your `init` function 
//// with an `assert` assignment, and store the result in your model. This way, you can be sure 
//// that if the game starts without errors, the sounds were loaded correctly.
//// 
//// Note that due to browser security restrictions, you will need some user interaction before playing
//// a sound. In my testing with Firefox, it was sufficient that the user had pressed a key or clicked 
//// with their mouse at any point before the sound was played.
//// 
//// ## Example:
//// 
//// ```gleam
//// pub fn main() {
////   canvas.start_fullscreen(init, update, view, "canvas", [], ["jump.js", "powerup.mp3"])
//// }
//// 
//// fn init() {
////   let assert Ok(jump_sound) = sound.new(0)
////   let assert Ok(powerup_sound) = sound.new(1)
////   Model( 
////     // ... 
////     jump_sound:,
////     powerup_sound:,
////   )
//// }
//// 
//// fn update(model: Model) {
////   // ... 
////   case player_has_jumped {
////     True -> sound.play(model.jump_sound)
////     False -> Nil
////   }
////   case player_has_powered_up {
////     True -> sound.play(model.powerup_sound)
////     False -> Nil
////   }
////  // ...
//// }

pub opaque type Sound {
  ZzFXSound(id: Int)
  ZzFXMSong(id: Int)
  FileSound(id: Int)
}

/// Creates a new `Sound` object from the sound file at the specified index in 
/// the `sound_sources` list that you passed in to the engine-starting function. 
/// Fails if the desired sound does not exist. For use in the `init` function.
pub fn new(id: Int) -> Result(Sound, Nil) {
  case do_check_type(id) {
    Ok(0) -> Ok(ZzFXSound(id))
    Ok(1) -> Ok(ZzFXMSong(id))
    Ok(2) -> Ok(FileSound(id))
    _ -> Error(Nil)
  }
}

@external(javascript, "../kitten_ffi.mjs", "checkSoundType")
fn do_check_type(id: Int) -> Result(Int, Nil)

/// Plays the specified sound.
pub fn play(sound: Sound) -> Nil {
  case sound {
    ZzFXMSong(id) -> do_play_song(id)
    ZzFXSound(id) -> do_play_sound(id)
    FileSound(id) -> do_play_file(id)
  }
}

@external(javascript, "../kitten_ffi.mjs", "playZzFXMSong")
fn do_play_song(id: Int) -> Nil

@external(javascript, "../kitten_ffi.mjs", "playZzFXSound")
fn do_play_sound(id: Int) -> Nil

@external(javascript, "../kitten_ffi.mjs", "playFileSound")
fn do_play_file(id: Int) -> Nil

/// Stops any currently playing sound.
@external(javascript, "../kitten_ffi.mjs", "stopSound")
pub fn stop() -> Nil
