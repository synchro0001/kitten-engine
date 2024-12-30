//// This module contains a few simple functions to work with mouse input.
//// These are intended for use inside your `update` function.
//// The custom `Button` types ensures that you can only check for real buttons and prevents misspellings.
//// 
//// ## Example: 
//// 
//// ```gleam
//// let new_pos = case mouse.was_pressed(mouse.LMB) && mouse.pos().x >=. 0.0 {
////   True -> pos |> vec2.add(Vec2(1.0, 0.0))
////   False -> pos
//// }
//// ```

import kitten/vec2.{type Vec2, Vec2}

pub type Button {
  LMB
  MMB
  RMB
}

fn to_code(button: Button) -> Int {
  case button {
    LMB -> 0
    MMB -> 1
    RMB -> 2
  }
}

/// Returns `True` if the mouse button was pressed in the time since the last frame,
/// but has not yet been released, and `False` otherwise.
/// Unless you specifically want the player to hold the mouse down for some time, 
/// you might be better off using the `was_pressed` and `was_released` functions.
pub fn is_down(button: Button) -> Bool {
  do_mouse_is_down(to_code(button))
}

@external(javascript, "../kitten_ffi.mjs", "mouseIsDown")
fn do_mouse_is_down(key: Int) -> Bool

/// Returns `True` if the mouse button was pressed in the time since the last frame,
/// and `False` otherwise.
pub fn was_pressed(button: Button) -> Bool {
  do_mouse_was_pressed(to_code(button))
}

@external(javascript, "../kitten_ffi.mjs", "mouseWasPressed")
fn do_mouse_was_pressed(key: Int) -> Bool

/// Returns `True` if the mouse button was released in the time since the last frame,
/// and `False` otherwise.
pub fn was_released(button: Button) -> Bool {
  do_mouse_was_released(to_code(button))
}

@external(javascript, "../kitten_ffi.mjs", "mouseWasReleased")
fn do_mouse_was_released(key: Int) -> Bool

/// Returns the position of the mouse in world coordinates.
pub fn pos() -> Vec2 {
  do_get_mouse_pos()
  |> vec2.from_tuple
}

@external(javascript, "../kitten_ffi.mjs", "getMousePosition")
fn do_get_mouse_pos() -> #(Float, Float)
