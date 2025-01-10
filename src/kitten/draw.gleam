//// This module contains functions for drawing to the canvas. It is intended
//// for use in your `view` function. Every `view` function should start with 
//// `draw.context`; from there, you can create a function pipe to draw all of
//// your objects. All positions and sizes are in world coordinates.
//// 
//// The `Color` type and the associated functions are defined in the `color` module.
//// 
//// ### Example: 
//// 
//// ```gleam
//// fn view(model: Model) {
////   draw.context()
////   |> draw.background(color.black)
////   |> draw.rect(model.pos, player_size, color.red)
////   Nil
//// }
//// ```

import gleam/list
import kitten/color.{type Color}
import kitten/vec2.{type Vec2}

pub type Context

/// Returns the 2D context of the canvas that you initiated the engine with.
/// Every `view` function should start with this.
/// 
/// ### Example: 
/// 
/// ```gleam
/// fn view(model: Model) {
///   draw.context()
///   |> draw.background(color.black)
///   |> draw.rect(model.pos, player_size, color.red)
///   Nil
/// }
/// ```
@external(javascript, "../kitten_ffi.mjs", "getContext")
pub fn context() -> Context

/// Draws a straight line between two points.
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.line(Vec2(0.0, 0.0), Vec2(0.0, 100.0), 5.0, color.black)
/// ```
pub fn line(
  ctx: Context,
  p1 p1: Vec2,
  p2 p2: Vec2,
  width width: Float,
  color color: Color,
) -> Context {
  do_draw_line(ctx, p1.x, p1.y, p2.x, p2.y, width, color.to_hexa(color))
}

@external(javascript, "../kitten_ffi.mjs", "drawLine")
fn do_draw_line(
  ctx: Context,
  x1: Float,
  y1: Float,
  x2: Float,
  y2: Float,
  width: Float,
  color: String,
) -> Context

/// Draws a rectangle with its *centre* at the specified position.
/// 
/// Use the `path` and `polygon` functions to create non-filled or tilted 
/// rectangles and other shapes.
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.rect(Vec2(0.0, 0.0), Vec2(50.0, 50.0), color.red)
/// ```
pub fn rect(
  ctx: Context,
  pos pos: Vec2,
  size size: Vec2,
  color color: Color,
) -> Context {
  do_draw_rect(ctx, pos.x, pos.y, size.x, size.y, color.to_hexa(color))
}

@external(javascript, "../kitten_ffi.mjs", "drawRect")
fn do_draw_rect(
  ctx: Context,
  x: Float,
  y: Float,
  w: Float,
  h: Float,
  color: String,
) -> Context

/// Draws a circle with its centre at the specified position.
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.circle(Vec2(0.0, 0.0), 20.0, color.red)
/// ```
pub fn circle(
  ctx: Context,
  pos pos: Vec2,
  r r: Float,
  color color: Color,
) -> Context {
  do_draw_circle(ctx, pos.x, pos.y, r, color.to_hexa(color))
}

@external(javascript, "../kitten_ffi.mjs", "drawCircle")
fn do_draw_circle(
  ctx: Context,
  x: Float,
  y: Float,
  r: Float,
  color: String,
) -> Context

/// Draws an ellipse from the specified parameters. 
/// 
/// This function is intended to give you full access to the `ellipse` API
/// of the HTML canvas, but should rarely be used on its own. Prefer the 
/// `circle` function for simple use cases or write wrappers around this one. 
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.ellipse(
///   Vec2(0.0, 0.0), 
///   50.0, 
///   20.0, 
///   math.pi /. 3.0, 
///   0.0, 
///   2.0 *. math.pi, 
///   False, 
///   2.0, 
///   color.red
/// )
/// ```
pub fn ellipse(
  ctx: Context,
  pos pos: Vec2,
  r1 r1: Float,
  r2 r2: Float,
  tilt tilt: Float,
  start_angle start_angle: Float,
  end_angle end_angle: Float,
  filled filled: Bool,
  width width: Float,
  color color: Color,
) -> Context {
  do_draw_ellipse(
    ctx,
    pos.x,
    pos.y,
    r1,
    r2,
    tilt,
    start_angle,
    end_angle,
    filled,
    width,
    color.to_hexa(color),
  )
}

@external(javascript, "../kitten_ffi.mjs", "drawEllipse")
fn do_draw_ellipse(
  ctx: Context,
  x: Float,
  y: Float,
  r1: Float,
  r2: Float,
  tilt: Float,
  start_angle: Float,
  end_angle: Float,
  filled: Bool,
  width: Float,
  color: String,
) -> Context

/// Draws some text with its *centre* at the specified position. 
/// The tilt must be given in radians.
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.text("kitten", Vec2(0.0, 0.0), 100.0, 300.0, "Arial", 0.0, color.red)
/// ```
pub fn text(
  ctx: Context,
  text text: String,
  pos pos: Vec2,
  size size: Float,
  weight weight: Float,
  font font: String,
  tilt tilt: Float,
  color color: Color,
) -> Context {
  do_draw_text(
    ctx,
    text,
    pos.x,
    pos.y,
    size,
    weight,
    font,
    tilt,
    color.to_hexa(color),
  )
}

@external(javascript, "../kitten_ffi.mjs", "drawText")
fn do_draw_text(
  ctx: Context,
  text: String,
  x: Float,
  y: Float,
  size: Float,
  weight: Float,
  font: String,
  tilt: Float,
  color: String,
) -> Context

/// Draws a non-closed path between the points, from the first to the last.
/// You can repeat the first point at the end to draw a closed path.
/// 
/// This function can be used to draw custom non-filled polygons.
/// 
/// ### Examples: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.path([Vec2(0.0, 0.0), Vec2(100.0, 0.0), Vec2(100.0, 100.0)], 5.0, color.red)
/// 
/// // a wrapper to draw a regular pentagon
/// fn draw_pentagon(ctx: Context, pos: Vec2, r: Float, tilt: Float, width: Float, color: Color) -> Context {
///   [0.0, 0.2, 0.4, 0.6, 0.8, 0.0]
///   |> list.map(fn(factor) {
///     {2 *. factor *. math.pi +. tilt}
///     |> vec2.unit
///     |> vec2.set_length(r)
///     |> vec2.add(pos)
///   })
///   |> draw.path(ctx, _, width, color)
/// }
/// ```
pub fn path(
  ctx: Context,
  points points: List(Vec2),
  width width: Float,
  color color: Color,
) {
  case points {
    [] -> ctx
    _ ->
      do_draw_path(
        ctx,
        list.map(points, vec2.to_tuple),
        width,
        color.to_hexa(color),
      )
  }
}

@external(javascript, "../kitten_ffi.mjs", "drawPath")
fn do_draw_path(
  ctx: Context,
  points: List(#(Float, Float)),
  width: Float,
  color: String,
) -> Context

/// Draws a *filled* polygon with its vertices at the specified points.
/// 
/// This function can be used to draw custom filled polygons.
/// 
/// 
/// ### Examples: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.polygon([Vec2(0.0, 0.0), Vec2(100.0, 0.0), Vec2(100.0, 100.0)], color.red)
/// 
/// // a wrapper to draw a regular pentagon
/// fn draw_pentagon(ctx: Context, pos: Vec2, r: Float, tilt: Float, color: Color) -> Context {
///   [0.0, 0.2, 0.4, 0.6, 0.8]
///   |> list.map(fn(factor) {
///     {2 *. factor *. math.pi +. tilt}
///     |> vec2.unit
///     |> vec2.set_length(r)
///     |> vec2.add(pos)
///   })
///   |> draw.polygon(ctx, _, color)
/// }
/// ```
pub fn polygon(ctx: Context, points points: List(Vec2), color color: Color) {
  case points {
    [] -> ctx
    _ ->
      do_draw_polygon(
        ctx,
        list.map(points, vec2.to_tuple),
        color.to_hexa(color),
      )
  }
}

@external(javascript, "../kitten_ffi.mjs", "drawPolygon")
fn do_draw_polygon(
  ctx: Context,
  points: List(#(Float, Float)),
  color: String,
) -> Context

pub opaque type Texture {
  Texture(img_id: Int, x: Int, y: Int, width: Int, height: Int)
}

/// Creates a new `Texture` from the following parameters: the index of the 
/// image that contains the texture, starting from 0, in the order of the list
/// that you passed into the engine-starting function from the `canvas` module;
/// the coordinates of the top-left pixel of the texture; and its size in pixels.
/// 
/// Since this function if fallible, it is highly recommended that you use it
/// as part of your `init` function with an `assert` assignment, and store it in 
/// your model. This way, you can be sure that if your game starts without errors,
/// the texture is correct.
/// 
/// ### Example: 
/// 
/// ```gleam
/// fn init() {
///   let assert Ok(player_texture) = draw.create_texture(0, 0, 0, 16, 16)
///   Model(
///     player_pos: Vec2(0.0, 0.0),
///     player_texture: player_texture
///   )
/// }
/// ```
pub fn create_texture(
  img_id: Int,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
) -> Result(Texture, Nil) {
  case check_img_id(img_id) {
    Ok(#(img_width, img_height))
      if x >= 0
      && y >= 0
      && width >= 0
      && height >= 0
      && x + width <= img_width
      && y + height <= img_height
    -> Ok(Texture(img_id, x, y, width, height))
    _ -> Error(Nil)
  }
}

@external(javascript, "../kitten_ffi.mjs", "checkImgId")
fn check_img_id(id: Int) -> Result(#(Int, Int), Nil)

/// Draws a `Texture` with its *centre* at the specified position. The texture
/// must be created using the `create_texture` function in this module.
/// The tilt must be given in radians.
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.texture(model.player_texture, Vec2(0.0, 0.0), Vec2(50.0, 50.0), 0.0)
/// ```
pub fn texture(
  ctx: Context,
  texture texture: Texture,
  pos pos: Vec2,
  size size: Vec2,
  tilt tilt: Float,
) {
  do_draw_texture(
    ctx,
    texture.img_id,
    texture.x,
    texture.y,
    texture.width,
    texture.height,
    pos.x,
    pos.y,
    size.x,
    size.y,
    tilt,
  )
}

@external(javascript, "../kitten_ffi.mjs", "drawTexture")
fn do_draw_texture(
  ctx: Context,
  img_id: Int,
  sx: Int,
  sy: Int,
  sw: Int,
  sh: Int,
  dx: Float,
  dy: Float,
  dw: Float,
  dh: Float,
  tilt: Float,
) -> Context

/// Sets the position of the camera, in world coordinates. Always call this
/// at the start of your `view` function and *before* setting the camera 
/// scale and rotation.
/// 
/// ### Example: 
/// 
/// ```gleam
/// fn view(model: Model) {
///   draw.context()
///   |> draw.set_camera_pos(Vec2(0.0, 100.0))
///   |> // ... rest of the function
/// }
/// ```
pub fn set_camera_pos(ctx: Context, new_pos: Vec2) -> Context {
  do_set_camera_pos(ctx, new_pos.x, new_pos.y)
}

@external(javascript, "../kitten_ffi.mjs", "setCameraPos")
fn do_set_camera_pos(
  ctx: Context,
  new_pos_x: Float,
  new_pos_y: Float,
) -> Context

/// Sets the scale of the camera. Always call this at the start of your `view`
/// function and *after* setting the camera position.
/// 
/// ### Example: 
/// 
/// ```gleam
/// fn view(model: Model) {
///   draw.context()
///   |> draw.set_camera_pos(Vec2(0.0, 100.0))
///   |> draw.set_camera_scale(2.0)
///   |> // ... rest of the function
/// }
/// ```
@external(javascript, "../kitten_ffi.mjs", "setCameraScale")
pub fn set_camera_scale(ctx: Context, new_scale: Float) -> Context

/// Sets the rotation of the camera in *radians*. Always call this at the start 
/// of your `view` function and *after* setting the camera position.
/// 
/// ### Example: 
/// 
/// ```gleam
/// fn view(model: Model) {
///   draw.context()
///   |> draw.set_camera_pos(Vec2(0.0, 100.0))
///   |> draw.set_camera_rotation(math.pi /. 2.0)
///   |> // ... rest of the function
/// }
/// ```
@external(javascript, "../kitten_ffi.mjs", "setCameraAngle")
pub fn set_camera_angle(ctx: Context, new_angle: Float) -> Context

/// Sets the background colour of the canvas.
/// 
/// ### Example: 
/// 
/// ```gleam
/// // inside a view() function
/// |> draw.background(color.slate_900)
/// ```
pub fn background(ctx: Context, color: Color) -> Context {
  do_set_background(ctx, color.to_hexa(color))
}

@external(javascript, "../kitten_ffi.mjs", "setBackground")
fn do_set_background(ctx: Context, color: String) -> Context
