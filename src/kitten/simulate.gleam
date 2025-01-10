//// This module contains functions for working with the physics system.
//// Please remember that the engine cannot simply run the physics for you,
//// and that you will need to write game logic specific to your game.
//// Think of this module as a collection of helper functions and not a 
//// full physics engine.
//// 
//// The functions in this module may be changed in the near future. 

import gleam/bool.{guard}
import gleam/float.{absolute_value as abs}
import gleam/list
import kitten/vec2.{type Vec2, Vec2}

/// Checks if the two rectangles, defined by their *centres* and sizes, are overlapping.
/// Sharing an edge or a corner but no inner space counts as an overlap.
///  
/// 
/// ### Examples:
/// 
/// ```gleam
/// simulate.is_overlapping(Vec2(0.0, 0.0), Vec2(10.0, 10.0), Vec2(5.0, 5.0), Vec2(10.0, 10.0))
/// // -> True
/// 
/// simulate.is_overlapping(Vec2(0.0, 0.0), Vec2(10.0, 10.0), Vec2(50.0, 50.0), Vec2(10.0, 10.0))
/// // -> False
/// ```
pub fn is_overlapping(
  pos1 pos1: Vec2,
  size1 size1: Vec2,
  pos2 pos2: Vec2,
  size2 size2: Vec2,
) -> Bool {
  abs(pos1.x -. pos2.x) *. 2.0 <=. size1.x +. size2.x
  && abs(pos1.y -. pos2.y) *. 2.0 <=. size1.y +. size2.y
}

/// Checks if a point lies within the rectangle, defined by its *centre* and size.
/// If the point lies on the edge of the rectangle, it is considered to be within it.
/// 
/// ### Examples:
/// 
/// ```gleam
/// simulate.is_within(Vec2(0.0, 0.0), Vec2(0.0, 0.0), Vec2(10.0, 10.0))
/// // -> True
/// 
/// simulate.is_within(Vec2(0.0, 0.0), Vec2(50.0, 50.0), Vec2(10.0, 10.0))
/// // -> False
/// ```
pub fn is_within(point point: Vec2, pos pos: Vec2, size size: Vec2) -> Bool {
  is_overlapping(point, Vec2(0.0, 0.0), pos, size)
}

/// Adjusts the position of an object by adding its velocity to it. Returns *only the new position*.
/// A simple alias for `vec2.add` that takes `delta_time` into account.
/// 
/// ### Example:
/// 
/// ```gleam
/// simulate.move(Vec2(0.0, 5.0), Vec2(10.0, 0.0))
/// // -> Vec2(10.0, 5.0) (approx.)
/// ```
pub fn move(pos pos: Vec2, vel vel: Vec2) -> Vec2 {
  vec2.scale(vel, delta_time())
  |> vec2.add(pos)
}

/// Adjusts the given velocity by applying a list of forces and taking the mass and `delta_time` into account.
/// Returns *only the new velocity*.
pub fn apply_forces(
  vel vel: Vec2,
  mass mass: Float,
  forces forces: List(Vec2),
) -> Vec2 {
  forces
  |> list.fold(Vec2(0.0, 0.0), vec2.add)
  |> vec2.scale(1.0 /. mass *. delta_time())
  |> vec2.add(vel)
}

/// Adjusts the given velocity by reducing its vertical component, taking `delta_time` into account.
pub fn apply_gravity(vel vel: Vec2, mass mass: Float, g g: Float) -> Vec2 {
  apply_forces(vel, mass, [Vec2(0.0, 0.0 -. g)])
}

/// Adjusts the given velocity by reducing all of its components, taking `delta_time` 
/// into account. `f` must be non-negative, or the function will fail at runtime.
pub fn apply_friction(vel vel: Vec2, f f: Float) -> Vec2 {
  let assert Ok(scale_factor) = float.power(f, delta_time())
  vec2.scale(vel, scale_factor)
}

/// Resolves the collision between two rectangular objects, defined by (in order) their *centre* positions,
/// sizes, velocities and masses; taking into account the elasticity and friction coefficients. Note that this 
/// funcion only changes the velocities of the objects and adjusts their positions to prevent an overlap, but 
/// does not apply any motion. Use the `move` function to do the latter.
/// 
/// Set the mass to 0.0 to simulate an object as static.
pub fn collision(
  obj1 obj1: #(Vec2, Vec2, Vec2, Float),
  obj2 obj2: #(Vec2, Vec2, Vec2, Float),
  e e: Float,
  f f: Float,
) -> #(#(Vec2, Vec2), #(Vec2, Vec2)) {
  let #(pos1, size1, vel1, mass1) = obj1
  let #(pos2, size2, vel2, mass2) = obj2

  use <- guard(
    !is_overlapping(pos1, size1, pos2, size2),
    return: #(#(pos1, vel1), #(pos2, vel2)),
  )

  let overlap_x = { size1.x +. size2.x } /. 2.0 -. abs(pos1.x -. pos2.x)
  let overlap_y = { size1.y +. size2.y } /. 2.0 -. abs(pos1.y -. pos2.y)

  let #(depth, normal) = case overlap_x <. overlap_y {
    True -> #(overlap_x, case pos1.x <. pos2.x {
      True -> Vec2(1.0, 0.0)
      False -> Vec2(-1.0, 0.0)
    })
    False -> #(overlap_y, case pos1.y <. pos2.y {
      True -> Vec2(0.0, 1.0)
      False -> Vec2(0.0, -1.0)
    })
  }

  let #(pos1_adjusted, pos2_adjusted) = case mass1, mass2 {
    0.0, 0.0 -> #(pos1, pos2)
    _, 0.0 -> #(pos1 |> vec2.subtract(normal |> vec2.scale(depth)), pos2)
    0.0, _ -> #(pos1, pos2 |> vec2.add(normal |> vec2.scale(depth)))
    _, _ -> #(
      pos1
        |> vec2.subtract(normal |> vec2.scale(0.5 *. depth)),
      pos2
        |> vec2.add(normal |> vec2.scale(0.5 *. depth)),
    )
  }
  // It seems like this part can and should be handled by the move() function,
  // but I will leave it in as a comment for now

  // let total_mass = mass1 +. mass2

  // let move1 = case mass1 {
  //   0.0 -> 0.0
  //   _ -> depth *. { mass2 /. total_mass }
  // }

  // let move2 = case mass2 {
  //   0.0 -> 0.0
  //   _ -> depth *. { mass1 /. total_mass }
  // }

  // let new_pos1 =
  //   normal
  //   |> vec2.scale(move1)
  //   |> vec2.subtract(pos1, _)

  // let new_pos2 =
  //   normal
  //   |> vec2.scale(move2)
  //   |> vec2.add(pos2)

  let rel_vel = vec2.subtract(vel2, vel1)
  let rel_vel_normal = vec2.dot_product(rel_vel, normal)
  use <- guard(rel_vel_normal >. 0.0, return: #(#(pos1, vel1), #(pos2, vel2)))

  let impulse =
    { -1.0 -. e } *. rel_vel_normal /. { 1.0 /. mass1 +. 1.0 /. mass2 }
  let impulse_vec = vec2.scale(normal, impulse)

  let adjustment1 = vec2.scale(impulse_vec, 1.0 /. mass1)
  let adjustment2 = vec2.scale(impulse_vec, 1.0 /. mass2)

  let tangent = Vec2(0.0 -. normal.y, normal.x)
  let rel_vel_tangent = vec2.dot_product(rel_vel, tangent)

  let friction_impulse =
    f *. rel_vel_tangent /. { 1.0 /. mass1 +. 1.0 /. mass2 }

  let friction_impulse_vec = tangent |> vec2.scale(friction_impulse)

  let friction_adjustment1 = vec2.scale(friction_impulse_vec, 1.0 /. mass1)
  let friction_adjustment2 = vec2.scale(friction_impulse_vec, 1.0 /. mass2)

  let vel1 =
    vel1
    |> vec2.subtract(adjustment1)
    |> vec2.add(friction_adjustment1)

  let vel2 =
    vel2
    |> vec2.add(adjustment2)
    |> vec2.subtract(friction_adjustment2)

  #(#(pos1_adjusted, vel1), #(pos2_adjusted, vel2))
}

/// Resolves collisions between every pair of objects in the list, defined by (in order) their *centre* 
/// position, size, velocity and mass; taking into account the elasticity and friction coefficients.
/// Note that this funcion only changes the velocities of the objects and adjusts their positions to 
/// prevent an overlap, but does not apply any motion. Use the `move` function to do the latter.
/// Set the mass to 0.0 to simulate an object as static.
pub fn collisions(
  objects objects: List(#(Vec2, Vec2, Vec2, Float)),
  e e: Float,
  f f: Float,
) -> List(#(Vec2, Vec2)) {
  case objects {
    [] -> []
    [obj] -> [#(obj.0, obj.2)]
    [first_object, ..other_objects] -> {
      let #(first_object, other_objects) =
        list.map_fold(other_objects, first_object, fn(first_object, object) {
          let #(
            #(first_object_pos, first_object_vel),
            #(object_pos, object_vel),
          ) =
            collision(
              #(first_object.0, first_object.1, first_object.2, first_object.3),
              #(object.0, object.1, object.2, object.3),
              e,
              f,
            )
          #(
            #(
              first_object_pos,
              first_object.1,
              first_object_vel,
              first_object.3,
            ),
            #(object_pos, object.1, object_vel, object.3),
          )
        })
      [#(first_object.0, first_object.2), ..collisions(other_objects, e, f)]
    }
  }
}

/// Converts the given position in world coordinates to its equivalent in 
/// screen coordinates, under the transformation specified in the `view` 
/// function in the *previous* frame. 
/// 
/// Screen coordinates start in the top-left corner of the canvas, with 
/// the x-axis pointing right and the y-axis pointing down, and have the same 
/// unit as world coordinates.
/// 
/// See the `draw` module for camera-related functions that specify this 
/// transformation.
pub fn world_to_screen(pos: Vec2) -> Vec2 {
  do_world_to_screen(pos.x, pos.y)
  |> vec2.from_tuple
}

@external(javascript, "../kitten_ffi.mjs", "worldToScreen")
fn do_world_to_screen(x: Float, y: Float) -> #(Float, Float)

/// Converts the given position in screen coordinates to its equivalent in 
/// world coordinates, under the transformation specified in the `view` 
/// function in the *previous* frame. 
/// 
/// Screen coordinates start in the top-left corner of the canvas, with 
/// the x-axis pointing right and the y-axis pointing down, and have the same 
/// unit as world coordinates.
/// 
/// See the `draw` module for camera-related functions that specify this 
/// transformation.
pub fn screen_to_world(pos: Vec2) -> Vec2 {
  do_screen_to_world(pos.x, pos.y)
  |> vec2.from_tuple
}

@external(javascript, "../kitten_ffi.mjs", "screenToWorld")
fn do_screen_to_world(x: Float, y: Float) -> #(Float, Float)

/// Checks if the line segment connecting the two points intersects a rectangle,
/// defined by its *centre* position and size. Uses a slightly unoptimised
/// Liang-Barsky algorithm.
/// 
/// ### Example:
/// 
/// ```gleam
/// is_intersecting(Vec2(0.0, -100.0), Vec2(0.0, 100.0), Vec2(0.0, 0.0), Vec2(100.0, 100.0))
/// // -> True
/// 
/// is_intersecting(Vec2(-100.0, -100.0), Vec2(-100.0, 100.0), Vec2(0.0, 0.0), Vec2(100.0, 100.0))
/// // -> False
/// ```
pub fn is_intersecting(
  point1 point1: Vec2,
  point2 point2: Vec2,
  pos pos: Vec2,
  size size: Vec2,
) -> Bool {
  let box_min = vec2.subtract(pos, vec2.scale(size, 0.5))
  let box_max = vec2.add(box_min, size)
  let p = [
    point1.x -. point2.x,
    point2.x -. point1.x,
    point1.y -. point2.y,
    point2.y -. point1.y,
  ]
  let q = [
    point1.x -. box_min.x,
    box_max.x -. point1.x,
    point1.y -. box_min.y,
    box_max.y -. point1.y,
  ]
  let #(t_min, t_max) =
    list.fold(list.zip(p, q), #(0.0, 1.0), fn(acc, pq) {
      let #(p_i, q_i) = pq
      let #(t_min, t_max) = acc
      case p_i == 0.0, q_i <. 0.0 {
        True, True -> #(1.0, 0.0)
        True, False -> acc
        False, _ -> {
          let t = q_i /. p_i
          case p_i <. 0.0 {
            True -> #(float.max(t_min, t), t_max)
            False -> #(t_min, float.min(t_max, t))
          }
        }
      }
    })
  t_min <=. t_max
}

/// Returns the amount of time since the previous frame was rendered, scaled so that when running
/// at 60 fps, this value should always be approximately `1.0`.
@external(javascript, "../kitten_ffi.mjs", "getDeltaTime")
pub fn delta_time() -> Float
