//// This module specifies a few simple mathematical functions for easy access
//// in game development. 
//// 
//// Honestly, I have no idea why these are not in the standard library.

import gleam/float

/// The cosine function.
@external(javascript, "../kitten_ffi.mjs", "cos")
pub fn cos(x: Float) -> Float

/// The sine function.
@external(javascript, "../kitten_ffi.mjs", "sin")
pub fn sin(x: Float) -> Float

/// The arctangent function. Note that `y` is the first argument.
@external(javascript, "../kitten_ffi.mjs", "atan2")
pub fn atan2(y: Float, x: Float) -> Float

/// The constant pi, accurate to 10 decimal places. 
pub const pi = 3.1415926535

/// Linearly interpolates between two numbers. Think of the result as the number 
/// `100 * p` percent of the way between `a` and `b`.
/// 
/// ### Example:
/// 
/// ```gleam
/// math.lerp(10.0, 20.0, 0.3)
/// // -> 13.0
/// ```
pub fn lerp(a: Float, b: Float, p: Float) -> Float {
  a *. { 1.0 -. p } +. b *. p
}

/// Returns `1.0` for positive numbers, `-1.0` for negative numbers and `0.0` for `0.0`.
/// 
/// ### Examples:
/// 
/// ```gleam
/// math.sign(-22.8)
/// // -> -1.0
/// 
/// math.sign(0.0)
/// // -> 0.0
/// ```
pub fn sign(a: Float) -> Float {
  case a >. 0.0, a <. 0.0 {
    True, _ -> 1.0
    _, True -> -1.0
    _, _ -> 0.0
  }
}

/// Converts the given angle in degrees to radians. The result is
/// guaranteed to fall between 0 and 2pi.
pub fn deg_to_rad(t: Float) -> Float {
  let assert Ok(t_rad) = { t /. 180.0 *. pi } |> float.modulo(2.0 *. pi)
  let assert Ok(t_rad) = { t_rad +. 2.0 *. pi } |> float.modulo(2.0 *. pi)
  t_rad
}

/// Converts the given angle in radians to degrees. The result is
/// guaranteed to fall between 0 and 360.
pub fn rad_to_deg(t: Float) -> Float {
  let assert Ok(t_deg) = { t /. pi *. 180.0 } |> float.modulo(360.0)
  let assert Ok(t_deg) = { t_deg +. 360.0 } |> float.modulo(360.0)
  t_deg
}
