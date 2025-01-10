//// This module defines a simple two-dimensional vector type and some helper functions to manipulate these vectors.
//// These are used throughout the engine.
//// 
//// ### Examples: 
//// 
//// ```gleam
//// let v1 = Vec2(10.0, 20.0)
//// let v2 = Vec2(40.0, 60.0)
//// 
//// vec2.add(v1, v2) 
//// // -> Vec2(50.0, 80.0)
//// 
//// vec2.dist(v1, v2) 
//// // -> 50.0
//// 
//// vec2.clamp(v1, Vec2(0.0, 0.0), Vec2(15.0, 15.0)) 
//// // -> Vec2(10.0, 15.0)
//// ```

import gleam/float
import kitten/math

pub type Vec2 {
  Vec2(x: Float, y: Float)
}

/// Adds two vectors component-wise.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.add(Vec2(10.0, 20.0), Vec2(5.0, -12.0))
/// // -> Vec2(15.0, 8.0)
/// ```
pub fn add(v1: Vec2, v2: Vec2) -> Vec2 {
  Vec2(v1.x +. v2.x, v1.y +. v2.y)
}

/// Subtracts two vectors component-wise.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.subtract(Vec2(10.0, 20.0), Vec2(5.0, -12.0))
/// // -> Vec2(5.0, 32.0)
/// ```
pub fn subtract(v1: Vec2, v2: Vec2) -> Vec2 {
  Vec2(v1.x -. v2.x, v1.y -. v2.y)
}

/// Multiplies two vectors component-wise.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.multiply(Vec2(10.0, 20.0), Vec2(5.0, -12.0))
/// // -> Vec2(50.0, -240.0)
/// ```
pub fn multiply(v1: Vec2, v2: Vec2) -> Vec2 {
  Vec2(v1.x *. v2.x, v1.y *. v2.y)
}

/// Calculates the [dot product](https://en.wikipedia.org/wiki/Dot_product) of two vectors.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.dot_product(Vec2(10.0, 20.0), Vec2(5.0, -12.0))
/// // -> -190.0
/// ```
pub fn dot_product(v1: Vec2, v2: Vec2) -> Float {
  v1.x *. v2.x +. v1.y *. v2.y
}

/// Linearly interpolates between two vectors. 
/// Think of the reult as the point `100 * p` percent along the line between them.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.lerp(Vec2(10.0, 20.0), Vec2(5.0, -12.0), 0.3)
/// // -> Vec2(8.5, 10.4)
/// ```
pub fn lerp(v1: Vec2, v2: Vec2, p: Float) -> Vec2 {
  add(scale(v1, 1.0 -. p), scale(v2, p))
}

/// Calculates the length / magnitude of a vector squared. 
/// Useful to make length comparisons slightly cheaper computationally.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.length_squared(Vec2(4.0, 3.0))
/// // -> 25.0
/// ```
pub fn length_squared(v: Vec2) -> Float {
  v.x *. v.x +. v.y *. v.y
}

/// Calculates the length / magnitude of a vector.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.length(Vec2(4.0, 3.0))
/// // -> 5.0
/// ```
pub fn length(v: Vec2) -> Float {
  let assert Ok(l) = float.square_root(length_squared(v))
  l
}

/// Scales the vector by the given factor. Works for all `Float`s.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.scale(Vec2(4.0, 3.0), 2.0)
/// // -> Vec2(8.0, 6.0)
/// ```
pub fn scale(v: Vec2, factor: Float) -> Vec2 {
  Vec2(v.x *. factor, v.y *. factor)
}

/// Calculates the distance between the endpoints of two vectors.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.dist(Vec2(4.0, 3.0), Vec2(8.0, 6.0))
/// // -> 5.0
/// ```
pub fn dist(v1: Vec2, v2: Vec2) -> Float {
  subtract(v1, v2) |> length
}

/// Returns a unit vector (i.e. vector of length `1.0`) in the given direction, 
/// `t` *radians* from the positive x-direction counterclockwise.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.length_squared(Vec2(4.0, 3.0))
/// // -> 25.0
/// ```
pub fn unit(t: Float) -> Vec2 {
  Vec2(math.cos(t), math.sin(t))
}

/// Returns a unit vector in the positive x direction.
/// 
/// Useful in function pipes.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.unit_x()
/// // -> Vec2(1.0, 0.0)
/// ```
pub fn unit_x() -> Vec2 {
  Vec2(1.0, 0.0)
}

/// Returns a unit vector in the positive y direction.
/// 
/// Useful in function pipes.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.unit_y()
/// // -> Vec2(0.0, 1.0)
/// ```
pub fn unit_y() -> Vec2 {
  Vec2(0.0, 1.0)
}

/// Returns a unit vector a random direction.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.unit_random()
/// // -> Vec2(0.6, -0.8)
/// ```
pub fn unit_random() -> Vec2 {
  unit(float.random() *. 2.0 *. math.pi)
}

/// Returns the vector that has the same direction as the original and the specified length.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.set_length(Vec2(6.0, 8.0), 1.0)
/// // -> Vec2(0.6, 0.8)
/// ```
pub fn set_length(v: Vec2, new_length: Float) -> Vec2 {
  scale(v, new_length /. length(v))
}

/// Clamps the length of a vector between a minimum and a maximum.
///  
/// ### Examples:
/// 
/// ```gleam
/// vec2.clamp_length(Vec2(6.0, 8.0), 1.0, 4.0)
/// // -> Vec2(1.2, 1.6)
/// 
/// vec2.clamp_length(Vec2(6.0, 8.0), 1.0, 20.0)
/// // -> Vec2(6.0, 8.0)
/// ```
pub fn clamp_length(v: Vec2, min_length: Float, max_length: Float) -> Vec2 {
  let new_length = float.clamp(length(v), min_length, max_length)
  set_length(v, new_length)
}

/// Clamps the vector component-wise between a minimum and a maximum.
///  
/// ### Examples:
/// 
/// ```gleam
/// Vec2(6.0, 8.0)
/// |> vec2.clamp(Vec2(1.0, 1.0), Vec2(5.0, 3.0))
/// // -> Vec2(5.0, 3.0)
/// 
/// Vec2(6.0, 8.0)
/// |> vec2.clamp(Vec2(5.0, 9.0), Vec2(10.0, 10.0))
/// // -> Vec2(6.0, 9.0)
/// ```
pub fn clamp(v: Vec2, min: Vec2, max: Vec2) -> Vec2 {
  Vec2(float.clamp(v.x, min.x, max.x), float.clamp(v.y, min.y, max.y))
}

/// Returns the normal vector (i.e. of length 1) in the same direction as the original.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.normalize(Vec2(6.0, 8.0))
/// // -> Vec2(0.6, 0.8)
/// ```
pub fn normalize(v: Vec2) -> Vec2 {
  set_length(v, 1.0)
}

/// Calculates the angle, in *radians*, 
/// that the given vector makes with the positive x-direction counterclockwise.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.angle(Vec2(1.0, 2.0))
/// // -> 1.107...
/// ```
pub fn angle(v: Vec2) -> Float {
  math.atan2(v.y, v.x)
}

/// Rotates the vector through the given angle, in *radians*, counterclockwise.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.rotate(Vec2(1.0, 2.0), 0.4636483268)
/// // -> Vec2(0.0, 2.236) (approx.)
/// ```
pub fn rotate(v: Vec2, t: Float) -> Vec2 {
  { angle(v) +. t }
  |> unit
  |> scale(length(v))
}

/// Returns the vector with the same length as the original, 
/// rotated through the angle `t` *radians* counterclockwise away from the positive x-direction.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.set_angle(Vec2(1.0, 2.0), math.pi /. 2.0)
/// // -> Vec2(0.0, 2.236) (approx.)
/// ```
pub fn set_angle(v: Vec2, t: Float) -> Vec2 {
  unit(t)
  |> scale(length(v))
}

/// Returns the vector rotated through 90 degrees or pi/2 radians to the left.
///
/// Useful in function pipes. 
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.rotate_left(Vec2(1.0, 2.0))
/// // -> Vec2(-2.0, 1.0)
/// ```
pub fn rotate_left(v: Vec2) -> Vec2 {
  Vec2(0.0 -. v.y, v.x)
}

/// Returns the vector rotated through 90 degrees or pi/2 radians to the right.
/// 
/// Useful in function pipes. 
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.rotate_right(Vec2(1.0, 2.0))
/// // -> Vec2(2.0, -1.0)
/// ```
pub fn rotate_right(v: Vec2) -> Vec2 {
  Vec2(v.y, 0.0 -. v.x)
}

/// Returns the vector with its direction flipped.
///  
/// ### Example:
/// 
/// ```gleam
/// vec2.invert(Vec2(1.0, 2.0))
/// // -> Vec2(-1.0, -2.0)
/// ```
pub fn invert(v: Vec2) -> Vec2 {
  Vec2(0.0 -. v.x, 0.0 -. v.y)
}

/// Checks if the two vectors are loosely equal to the specified precision,
/// similar to `float.loosely_equals`. 
/// The comparison is made component-wise.
///  
/// ### Examples:
/// 
/// ```gleam
/// vec2.loosely_equals(Vec2(1.0, 2.0), Vec2(1.01, 2.01), 0.05)
/// // -> True
/// 
/// vec2.loosely_equals(Vec2(1.0, 2.0), Vec2(1.01, 2.01), 0.001)
/// // -> False
/// ```
pub fn loosely_equals(v1: Vec2, v2: Vec2, precision: Float) -> Bool {
  float.loosely_equals(v1.x, v2.x, precision)
  && float.loosely_equals(v1.y, v2.y, precision)
}

/// A simple identity function specific to the Vec2 type. 
/// 
/// Useful in function pipes for extra type safety and readability.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.id(Vec2(1.0, 2.0))
/// // -> Vec2(1.0, 2.0)
/// ```
pub fn id(v: Vec2) -> Vec2 {
  v
}

/// Constructs a `Vec2` from a tuple of the x and y components. 
/// 
/// Useful in function pipes, but prefer to use the actual constructor otherwise.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.from_tuple(6.0, 8.0)
/// // -> Vec2(6.0, 8.0)
/// ```
pub fn from_tuple(x_y: #(Float, Float)) -> Vec2 {
  Vec2(x_y.0, x_y.1)
}

/// Converts a `Vec2` to a tuple of the x and y components.
///  
/// Useful in function pipes.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.to_tuple(Vec2(6.0, 8.0))
/// // -> #(6.0, 8.0)
/// ```
pub fn to_tuple(v: Vec2) -> #(Float, Float) {
  #(v.x, v.y)
}

/// Extracts the x-component of the vector.
/// 
/// Useful in function pipes, but prefer to use the `v.x` syntax otherwise.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.get_x(Vec2(6.0, 8.0))
/// // -> 6.0
/// ```
pub fn get_x(v: Vec2) -> Float {
  v.x
}

/// Extracts the y-component of the vector.
/// 
/// Useful in function pipes, but prefer to use the `v.y` syntax otherwise.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.get_y(Vec2(6.0, 8.0))
/// // -> 8.0
/// ```
pub fn get_y(v: Vec2) -> Float {
  v.y
}

/// Sets the x-component of the vector.
/// 
/// Useful in function pipes.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.set_x(Vec2(6.0, 8.0), 3.0)
/// // -> Vec2(3.0, 8.0)
/// ```
pub fn set_x(v: Vec2, new_x: Float) -> Vec2 {
  Vec2(x: new_x, y: v.y)
}

/// Sets the y-component of the vector.
/// 
/// Useful in function pipes.
/// 
/// ### Example:
/// 
/// ```gleam
/// vec2.set_y(Vec2(6.0, 8.0), 5.0)
/// // -> Vec2(6.0, 5.0)
/// ```
pub fn set_y(v: Vec2, new_y: Float) -> Vec2 {
  Vec2(x: v.x, y: new_y)
}

/// Clamps the x-component of the vector between a minimum and a maximum.
/// 
/// ### Examples:
/// 
/// ```gleam
/// vec2.clamp_x(Vec2(6.0, 8.0), 3.0, 5.0)
/// // -> Vec2(5.0, 8.0)
/// 
/// vec2.clamp_x(Vec2(6.0, 8.0), 3.0, 7.0)
/// // -> Vec2(6.0, 8.0)
/// ```
pub fn clamp_x(v: Vec2, min_x: Float, max_x: Float) -> Vec2 {
  float.clamp(v.x, min_x, max_x)
  |> set_x(v, _)
}

/// Clamps the y-component of the vector between a minimum and a maximum.
/// 
/// ### Examples:
/// 
/// ```gleam
/// vec2.clamp_y(Vec2(6.0, 8.0), 5.0, 7.0)
/// // -> Vec2(6.0, 7.0)
/// 
/// vec2.clamp_y(Vec2(6.0, 8.0), 5.0, 9.0)
/// // -> Vec2(6.0, 8.0)
/// ```
pub fn clamp_y(v: Vec2, min_y: Float, max_y: Float) -> Vec2 {
  float.clamp(v.y, min_y, max_y)
  |> set_y(v, _)
}
