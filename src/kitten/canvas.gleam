//// This module contains functions for starting the engine, for use within your `main` function.
//// You should only ever start the engine once in your code. For most use cases, `start_window`
//// should be preferable as it  automatically stretches your canvas to the size of the window and 
//// updates it when the window is resized.
//// 
//// ### Example:
//// 
//// ```gleam
//// pub fn main() {
////   canvas.start_window(init, update, view, "kitten-canvas", 1920.0, 1080.0, ["kitten.png", "background.png"], ["theme-song.js"])
//// }
//// ```

/// Starts the engine on the canvas with the specified id. The canvas width and height must be given in 
/// world coordinates. The canvas will automatically be stretched to occupy as much of the window as possible
/// while preserving the aspect ratio between `canvas_width` and `canvas_height`, and adjusted when the window 
/// is resized. Note that the margins around the canvas will be coloured when using the `draw.background` 
/// function. Use CSS if you need to see the real canvas size for debugging:
/// 
/// ```css
/// canvas {
///   border: 1px solid red;
/// }
/// ```
/// 
/// The canvas must already exist in your HTML file.  Use the `draw` and `sound` modules to access the images 
/// and sounds from the files specified in `image_sources` and `sound_sources`.
pub fn start_window(
  init init: fn() -> m,
  update update: fn(m) -> m,
  view view: fn(m) -> Nil,
  canvas_id canvas_id: String,
  canvas_width canvas_width: Float,
  canvas_height canvas_height: Float,
  image_sources image_sources: List(String),
  sound_sources sound_sources: List(String),
) -> Nil {
  do_start_window(
    init,
    update,
    view,
    canvas_id,
    canvas_width,
    canvas_height,
    image_sources,
    sound_sources,
  )
}

@external(javascript, "../kitten_ffi.mjs", "startWindow")
fn do_start_window(
  init: fn() -> m,
  update: fn(m) -> m,
  view: fn(m) -> Nil,
  canvas_id: String,
  canvas_width: Float,
  canvas_height: Float,
  image_sources: List(String),
  sound_sources: List(String),
) -> Nil

/// Starts the engine on the canvas with the specified id, but does not change its size. The canvas width 
/// and height must be given in world coordinates. The canvas will automatically be scaled so as to fit the 
/// world defined by `canvas_width` and `canvas_height`. For the best appearance, the ratio between these needs
/// to match the canvas's aspect ratio.
/// 
/// The canvas must already exist in your HTML file.  Use the `draw` and `sound` modules to access the images 
/// and sounds from the files specified in `image_sources` and `sound_sources`.
/// 
/// Useful when embedding the game in a static webpage.
pub fn start_embedded(
  init init: fn() -> m,
  update update: fn(m) -> m,
  view view: fn(m) -> Nil,
  canvas_id canvas_id: String,
  canvas_width canvas_width: Float,
  canvas_height canvas_height: Float,
  image_sources image_sources: List(String),
  sound_sources sound_sources: List(String),
) -> Nil {
  do_start_embedded(
    init,
    update,
    view,
    canvas_id,
    canvas_width,
    canvas_height,
    image_sources,
    sound_sources,
  )
}

@external(javascript, "../kitten_ffi.mjs", "startEmbedded")
fn do_start_embedded(
  init: fn() -> m,
  update: fn(m) -> m,
  view: fn(m) -> Nil,
  canvas_id: String,
  canvas_width: Float,
  canvas_height: Float,
  image_sources: List(String),
  sound_sources: List(String),
) -> Nil

/// Scales up the canvas to fullscreen mode if `toggle` is set to `True` and exits fullscreen mode 
/// if `toggle` is set to `False`. Note that due to browser security restrictions, the request to 
/// enter fullscreen mode must come from a user interaction. Therefore, it cannot be part of the 
/// `init` function and must be bound to something like a mouse click or a key press. 
@external(javascript, "../kitten_ffi.mjs", "toggleFullscreen")
pub fn toggle_fullscreen(toggle: Bool) -> Nil
