//// This module defines a simple two-dimensional intiger vector type and some helper functions to manipulate these vectors.
//// These are used throughout the engine.
//// 
//// ## Examples: 
//// 
//// ```gleam
//// let v1 = Vec2i(10, 20)
//// let v2 = Vec2i(40, 60)
//// 
//// vec2i.add(v1, v2) 
//// // -> Vec2(50, 80)
//// 
//// vec2i.dist(v1, v2) 
//// // -> 50.0
//// 
//// vec2i.clamp(v1, Vec2(0, 0), Vec2(15, 15)) 
//// // -> Vec2(10, 15)
//// ```

import gleam/float
import gleam/int

import kitten/vec2

/// An intiger-only version of [Vec2]
pub type Vec2i {
  Vec2i(x: Int, y: Int)
}

/// Add two Vec2i types together
pub fn add(a: Vec2i, b: Vec2i) {
  Vec2i(a.x + b.x, a.y + b.y)
}

/// Clamps the vector component-wise between the minimum andd the maximum
pub fn clamp(v: Vec2i, min min: Vec2i, max max: Vec2i) {
  Vec2i(int.clamp(v.x, min.x, max.x), int.clamp(v.y, min.y, max.y))
}

/// Calculates the [dot product](https://en.wikipedia.org/wiki/Dot_product) of two vectors.
pub fn dot_product(v1: Vec2i, v2: Vec2i) {
  v1.x * v2.x + v1.y * v2.y
}

pub fn get_x(v: Vec2i) -> Int {
  v.x
}

pub fn get_y(v: Vec2i) -> Int {
  v.y
}

pub fn id(v: Vec2i) -> Vec2i {
  v
}

/// Returns the Vec2i with its direction flipped.
///
/// ### Example:
/// 
/// ```gleam
/// vec2i.invert(Vec2i(1, 2))
/// // -> Vec2i(-1, -2)
/// ```
pub fn invert(v: Vec2i) -> Vec2i {
  Vec2i(0 - v.x, 0 - v.y)
}

pub fn subtract(a: Vec2i, b: Vec2i) -> Vec2i {
  Vec2i(a.x - b.x, a.y - b.y)
}

pub type Vec2iConversionError {
  XNotWhole
  YNotWhole
  BothNotWhole
}

pub fn from_vec2(v: vec2.Vec2) -> Result(Vec2i, Vec2iConversionError) {
  case
    { float.modulo(v.x, by: 1.0) == Ok(1.0) },
    { float.modulo(v.y, by: 1.0) == Ok(1.0) }
  {
    // SAFETY: We have already ensured that both are whole numbers, thus
    // rounding to the nearest whole number does not change its value.
    // This was just the easiest way to force it into a whole number.
    True, True -> Ok(Vec2i(float.round(v.x), float.round(v.y)))
    True, False -> Error(XNotWhole)
    False, True -> Error(YNotWhole)
    False, False -> Error(BothNotWhole)
  }
}

pub fn to_vec2(v: Vec2i) -> vec2.Vec2 {
  vec2.Vec2(int.to_float(v.x), int.to_float(v.y))
}
