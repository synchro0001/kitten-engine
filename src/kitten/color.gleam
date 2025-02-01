//// This module contains functions for working with colours.
//// 
//// For most use cases, you should be able to import a handful of the
//// pre-defined colours and use them in your code. These colours are 
//// taken directly from [Pico CSS](https://picocss.com/docs/colors). Use
//// their website to browse the colour collection online.
//// 
//// If you need to define custom colours though, this module provides 
//// functions for that too. Since they are fallible, it is highly 
//// recommended that you use them inside your `init` function with an
////  `assert` assignment, and store the result in your model (you might
//// even go as far as to define a custom `Palette` type). This way, 
//// you can be sure that if your game starts without errors, the colours 
//// are correct.
//// 
//// ### Examples
//// 
//// ```gleam
//// // inside a view() function
//// |> draw.rect(Vec2(0.0, 0.0), Vec2(50.0, 50.0), color.fuchsia_450)
//// ```
//// 
//// ```gleam 
//// type Model {
////   Model(player_pos: Vec2, palette: Palette)
//// }
//// 
//// type Palette {
////   Palette(transparent_blue: Color, bright_green: Color) 
//// }
//// 
//// fn init() {
////   let assert Ok(transparent_blue) = color.blue_600 |> color.set_a(0.5)
////   let assert Ok(bright_green) = color.from_hex("2EFC0A")
////   Model(
////     player_pos: Vec2(0.0, 0.0), 
////     palette: Palette(transparent_blue:, bright_green:)
////   )
//// } 
//// ```

import gleam/float
import gleam/int
import gleam/result
import gleam/string

pub opaque type Color {
  Color(r: Int, g: Int, b: Int, a: Float)
}

/// Returns the R value of the colour in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_r
/// // -> 237
/// ```
pub fn get_r(color: Color) -> Int {
  color.r
}

/// Returns the G value of the colour in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_g
/// // -> 42
/// ```
pub fn get_g(color: Color) -> Int {
  color.g
}

/// Returns the B value of the colour in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_b
/// // -> 172
/// ```
pub fn get_b(color: Color) -> Int {
  color.b
}

/// Returns the transparency (A) value of the colour.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_a
/// // -> 1.0
/// ```
pub fn get_a(color: Color) -> Float {
  color.a
}

/// Sets the R value of the colour in RGB encoding. 
/// R must be between 0 and 255, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_r(255)
/// // -> Ok(Color(255, 42, 172, 1.0))
/// ```
pub fn set_r(color: Color, new_r: Int) -> Result(Color, Nil) {
  from_rgba(new_r, color.g, color.b, color.a)
}

/// Sets the G value of the colour in RGB encoding.
/// G must be between 0 and 255, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_g(255)
/// // -> Ok(Color(237, 255, 172, 1.0))
/// ```
pub fn set_g(color: Color, new_g: Int) -> Result(Color, Nil) {
  from_rgba(color.r, new_g, color.b, color.a)
}

/// Sets the B value of the colour in RGB encoding.
/// B must be between 0 and 255, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_g(255)
/// // -> Ok(Color(237, 42, 255, 1.0))
/// ```
pub fn set_b(color: Color, new_b: Int) -> Result(Color, Nil) {
  from_rgba(color.r, color.g, new_b, color.a)
}

/// Sets the transparency (A) value of the colour.
/// A must be between 0.0 and 1.0, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_a(0.8)
/// // -> Ok(Color(237, 42, 172, 0.8))
/// ```
pub fn set_a(color: Color, new_a: Float) -> Result(Color, Nil) {
  from_rgba(color.r, color.g, color.b, new_a)
}

/// Creates a `Color` from R, G and B values in RGB encoding, with A 
/// automatically set to 1.0. The values must be between 0 and 255,
/// otherwise the function fails.
/// 
/// ### Examples:
/// 
/// ```gleam
/// color.from_rgb(237, 42, 172)
/// // -> Ok(Color(237, 42, 172, 1.0))
/// 
/// color.from_rgb(237, 42, 256)
/// // -> Error(Nil)
/// ```
pub fn from_rgb(r: Int, g: Int, b: Int) -> Result(Color, Nil) {
  case r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255 {
    True -> Ok(Color(r, g, b, 1.0))
    False -> Error(Nil)
  }
}

/// Creates a `Color` from R, G, B and A values in RGB encoding. 
/// R, G and B must be between 0 and 255 and A between 0.0 and 1.0, 
/// otherwise the function fails.
/// 
/// ### Examples:
/// 
/// ```gleam
/// color.from_rgba(237, 42, 172, 0.8)
/// // -> Ok(Color(237, 42, 172, 0.8))
/// 
/// color.from_rgba(237, 42, 172, 2.0)
/// // -> Error(Nil)
/// ```
pub fn from_rgba(r: Int, g: Int, b: Int, a: Float) -> Result(Color, Nil) {
  case
    r >= 0
    && r <= 255
    && g >= 0
    && g <= 255
    && b >= 0
    && b <= 255
    && a >=. 0.0
    && a <=. 1.0
  {
    True -> Ok(Color(r, g, b, a))
    False -> Error(Nil)
  }
}

/// Converts a `Color` to its R, G and B values in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.to_rgb
/// // -> #(237, 42, 172)
/// ```
pub fn to_rgb(color: Color) -> #(Int, Int, Int) {
  #(color.r, color.g, color.b)
}

/// Converts a `Color` to its R, G, B and A values in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.to_rgba
/// // -> #(237, 42, 172, 1.0)
/// ```
pub fn to_rgba(color: Color) -> #(Int, Int, Int, Float) {
  #(color.r, color.g, color.b, color.a)
}

/// Returns the H value of the colour in HSL encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_h
/// // -> 320
/// ```
pub fn get_h(color: Color) -> Int {
  to_hsl(color).0
}

/// Returns the S value of the colour in HSL encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_s
/// // -> 84
/// ```
pub fn get_s(color: Color) -> Int {
  to_hsl(color).1
}

/// Returns the L value of the colour in HSL encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.get_l
/// // -> 55
/// ```
pub fn get_l(color: Color) -> Int {
  to_hsl(color).2
}

/// Sets the H value of the colour in HSL encoding.
/// H must be between 0 and 359, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_h(100)
/// // -> Ok(Color(108, 237, 44, 1.0))
/// ```
pub fn set_h(color: Color, new_h: Int) -> Result(Color, Nil) {
  let #(_, s, l, a) = to_hsla(color)
  from_hsla(new_h, s, l, a)
}

/// Sets the S value of the colour in HSL encoding.
/// S must be between 0 and 100, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_s(50)
/// // -> Ok(Color(198, 83, 159, 1.0))
/// ```
pub fn set_s(color: Color, new_s: Int) -> Result(Color, Nil) {
  let #(h, _, l, a) = to_hsla(color)
  from_hsla(h, new_s, l, a)
}

/// Sets the L value of the colour in HSL encoding.
/// L must be between 0 and 100, otherwise the function fails.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.set_l(50)
/// // -> Ok(Color(235, 20, 163, 1.0))
/// ```
pub fn set_l(color: Color, new_l: Int) -> Result(Color, Nil) {
  let #(h, s, _, a) = to_hsla(color)
  from_hsla(h, s, new_l, a)
}

/// Converts a `Color` to its H, S and L values in HSL encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.to_hsl
/// // -> #(320, 84, 55)
/// ```
pub fn to_hsl(color: Color) -> #(Int, Int, Int) {
  let r = int.to_float(color.r) /. 255.0
  let g = int.to_float(color.g) /. 255.0
  let b = int.to_float(color.b) /. 255.0
  let #(c_max, c_min) = case r >. g, r >. b, g >. b {
    True, True, True -> #(r, b)
    True, True, False -> #(r, g)
    True, False, True -> panic as "impossible"
    True, False, False -> #(b, g)
    False, True, True -> #(g, b)
    False, True, False -> panic as "impossible"
    False, False, True -> #(g, r)
    False, False, False -> #(b, r)
  }
  let d = c_max -. c_min
  let l = { c_max +. c_min } /. 2.0
  let s = case d {
    0.0 -> 0.0
    _ -> d /. { 1.0 -. float.absolute_value(2.0 *. l -. 1.0) }
  }
  let assert Ok(h) =
    case d, c_max == r, c_max == g, c_max == b {
      0.0, _, _, _ -> 0.0
      _, True, _, _ -> {
        let assert Ok(tmp) = float.modulo({ g -. b } /. d, 6.0)
        60.0 *. tmp
      }
      _, _, True, _ -> 60.0 *. { { b -. r } /. d +. 2.0 }
      _, _, _, True -> 60.0 *. { { r -. g } /. d +. 4.0 }
      _, _, _, _ -> panic as "unreachable"
    }
    |> float.modulo(360.0)

  #(float.round(h), float.round(s *. 100.0), float.round(l *. 100.0))
}

/// Converts a `Color` to its H, S, L and A values in HSL encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.to_hsla
/// // -> #(320, 84, 55, 1.0)
/// ```
pub fn to_hsla(color: Color) -> #(Int, Int, Int, Float) {
  let #(h, s, l) = to_hsl(color)
  #(h, s, l, color.a)
}

/// Creates a `Color` from H, S and L values in HSL encoding, with A 
/// automatically set to 1.0. H must be between 0 and 359, and S and L
/// between 0 and 100, otherwise the function fails.
/// 
/// ### Examples:
/// 
/// ```gleam
/// color.from_hsl(240, 90, 80)
/// // -> Ok(Color(158, 158, 250, 1.0))
/// 
/// color.from_hsl(400, 90, 80)
/// // -> Error(Nil)
/// ```
pub fn from_hsl(h: Int, s: Int, l: Int) -> Result(Color, Nil) {
  case h >= 0 && h < 360 && s >= 0 && s <= 100 && l >= 0 && l <= 100 {
    True -> {
      let c0 = s * { 100 - int.absolute_value(2 * l - 100) }
      let c = int.to_float(c0) /. 10_000.0
      let assert Ok(tmp) = float.modulo(int.to_float(h) /. 60.0, 2.0)
      let x = c *. { 1.0 -. float.absolute_value(tmp -. 1.0) }
      let #(r0, g0, b0) = case Nil {
        _ if 0 <= h && h < 60 -> #(c, x, 0.0)
        _ if 60 <= h && h < 120 -> #(x, c, 0.0)
        _ if 120 <= h && h < 180 -> #(0.0, c, x)
        _ if 180 <= h && h < 240 -> #(0.0, x, c)
        _ if 240 <= h && h < 300 -> #(x, 0.0, c)
        _ if 300 <= h && h < 360 -> #(c, 0.0, x)
        _ -> panic as "unreachable"
      }
      let m = int.to_float(l) /. 100.0 -. c /. 2.0
      Ok(Color(
        float.round(255.0 *. { r0 +. m }),
        float.round(255.0 *. { g0 +. m }),
        float.round(255.0 *. { b0 +. m }),
        1.0,
      ))
    }
    False -> Error(Nil)
  }
}

/// Creates a `Color` from H, S, L and A values in HSL encoding. 
/// H must be between 0 and 359, S and L between 0 and 100, and A 
/// between 0.0 and 1.0, otherwise the function fails.
/// 
/// ### Examples:
/// 
/// ```gleam
/// color.from_hsla(240, 90, 80, 0.8)
/// // -> Ok(Color(158, 158, 250, 0.8))
/// 
/// color.from_hsla(240, 90, 80, 2.0)
/// // -> Error(Nil)
/// ```
pub fn from_hsla(h: Int, s: Int, l: Int, a: Float) -> Result(Color, Nil) {
  case a >=. 0.0 && a <=. 1.0, from_hsl(h, s, l) {
    True, Ok(Color(r, g, b, _)) -> Ok(Color(r, g, b, a))
    _, _ -> Error(Nil)
  }
}

/// Converts a `Color` to a hex string of the form "#RRGGBB" in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.to_hex
/// // -> "#ED2AAC"
/// ```
pub fn to_hex(color: Color) -> String {
  "#"
  <> string.pad_start(int.to_base16(color.r), 2, "0")
  <> string.pad_start(int.to_base16(color.g), 2, "0")
  <> string.pad_start(int.to_base16(color.b), 2, "0")
}

/// Converts a `Color` to a hex string of the form "#RRGGBBAA" in RGB encoding.
/// 
/// ### Example:
/// 
/// ```gleam
/// color.fuchsia_450
/// |> color.to_hexa
/// // -> "#ED2AACFF"
/// ```
pub fn to_hexa(color: Color) -> String {
  to_hex(color)
  <> string.pad_start(
    int.to_base16({ color.a *. 255.0 } |> float.round),
    2,
    "0",
  )
}

/// Creates a `Color` from a hex string of the form "#RRGGBB"
/// with R, G and B values in RGB encoding and A automatically set to 1.0. 
/// The values must be between 0 and 255, otherwise the function fails.
/// 
/// ### Examples:
/// 
/// ```gleam
/// color.from_hex("#ED2AAC"))
/// // -> Ok(Color(237, 42, 172, 1.0))
/// 
/// color.from_hex("#ZZZZZZ")
/// // -> Error(Nil)
/// ```
pub fn from_hex(hex_string: String) -> Result(Color, Nil) {
  case string.to_graphemes(hex_string) {
    ["#", r1, r2, g1, g2, b1, b2] -> {
      use r <- result.try(int.base_parse(r1 <> r2, 16))
      use g <- result.try(int.base_parse(g1 <> g2, 16))
      use b <- result.try(int.base_parse(b1 <> b2, 16))
      from_rgb(r, g, b)
    }
    _ -> Error(Nil)
  }
}

/// Creates a `Color` from a hex string of the form "#RRGGBBAA" 
/// with R, G, and B values in RGB encoding. R, G, B and A must be 
/// between 0 and 255 otherwise the function fails.
/// 
/// ### Examples:
/// 
/// ```gleam
/// color.from_hexa("#ED2AACFF"))
/// // -> Ok(Color(237, 42, 172, 1.0))
/// 
/// color.from_hexa("#ZZZZZZZZ")
/// // -> Error(Nil)
/// ```
pub fn from_hexa(hex_string: String) -> Result(Color, Nil) {
  case string.to_graphemes(hex_string) {
    ["#", r1, r2, g1, g2, b1, b2, a1, a2] -> {
      use r <- result.try(int.base_parse(r1 <> r2, 16))
      use g <- result.try(int.base_parse(g1 <> g2, 16))
      use b <- result.try(int.base_parse(b1 <> b2, 16))
      use a <- result.try(int.base_parse(a1 <> a2, 16))
      from_rgba(r, g, b, int.to_float(a) /. 255.0)
    }
    _ -> Error(Nil)
  }
}

/// Returns a random color. The R, G and B values are picked randomly,
/// but A is always set to 1.0.
/// 
/// ### Example: 
/// 
/// ```gleam
/// color.random()
/// // -> Color(237, 42, 172, 1.0)
/// ```
pub fn random() -> Color {
  let r = int.random(256)
  let g = int.random(256)
  let b = int.random(256)
  Color(r, g, b, 1.0)
}

pub const white = Color(r: 255, g: 255, b: 255, a: 1.0)

pub const black = Color(r: 0, g: 0, b: 0, a: 1.0)

pub const amber = Color(r: 255, g: 191, b: 0, a: 1.0)

pub const amber_050 = Color(r: 252, g: 239, b: 217, a: 1.0)

pub const amber_100 = Color(r: 253, g: 222, b: 166, a: 1.0)

pub const amber_150 = Color(r: 254, g: 204, b: 99, a: 1.0)

pub const amber_200 = Color(r: 255, g: 191, b: 0, a: 1.0)

pub const amber_250 = Color(r: 232, g: 174, b: 1, a: 1.0)

pub const amber_300 = Color(r: 216, g: 161, b: 0, a: 1.0)

pub const amber_350 = Color(r: 199, g: 148, b: 0, a: 1.0)

pub const amber_400 = Color(r: 183, g: 136, b: 0, a: 1.0)

pub const amber_450 = Color(r: 167, g: 124, b: 0, a: 1.0)

pub const amber_500 = Color(r: 151, g: 112, b: 0, a: 1.0)

pub const amber_550 = Color(r: 135, g: 100, b: 0, a: 1.0)

pub const amber_600 = Color(r: 120, g: 88, b: 0, a: 1.0)

pub const amber_650 = Color(r: 105, g: 77, b: 0, a: 1.0)

pub const amber_700 = Color(r: 91, g: 66, b: 0, a: 1.0)

pub const amber_750 = Color(r: 77, g: 55, b: 0, a: 1.0)

pub const amber_800 = Color(r: 63, g: 45, b: 0, a: 1.0)

pub const amber_850 = Color(r: 49, g: 35, b: 2, a: 1.0)

pub const amber_900 = Color(r: 35, g: 26, b: 3, a: 1.0)

pub const amber_950 = Color(r: 22, g: 16, b: 3, a: 1.0)

pub const azure = Color(r: 1, g: 114, b: 173, a: 1.0)

pub const azure_050 = Color(r: 233, g: 242, b: 252, a: 1.0)

pub const azure_100 = Color(r: 209, g: 229, b: 251, a: 1.0)

pub const azure_150 = Color(r: 183, g: 217, b: 252, a: 1.0)

pub const azure_200 = Color(r: 155, g: 204, b: 253, a: 1.0)

pub const azure_250 = Color(r: 121, g: 192, b: 255, a: 1.0)

pub const azure_300 = Color(r: 81, g: 180, b: 255, a: 1.0)

pub const azure_350 = Color(r: 1, g: 170, b: 255, a: 1.0)

pub const azure_400 = Color(r: 2, g: 154, b: 232, a: 1.0)

pub const azure_450 = Color(r: 1, g: 140, b: 212, a: 1.0)

pub const azure_500 = Color(r: 1, g: 127, b: 192, a: 1.0)

pub const azure_550 = Color(r: 1, g: 114, b: 173, a: 1.0)

pub const azure_600 = Color(r: 2, g: 101, b: 154, a: 1.0)

pub const azure_650 = Color(r: 1, g: 88, b: 135, a: 1.0)

pub const azure_700 = Color(r: 1, g: 76, b: 117, a: 1.0)

pub const azure_750 = Color(r: 1, g: 64, b: 99, a: 1.0)

pub const azure_800 = Color(r: 3, g: 52, b: 82, a: 1.0)

pub const azure_850 = Color(r: 5, g: 41, b: 64, a: 1.0)

pub const azure_900 = Color(r: 6, g: 30, b: 47, a: 1.0)

pub const azure_950 = Color(r: 4, g: 18, b: 29, a: 1.0)

pub const blue = Color(r: 32, g: 96, b: 223, a: 1.0)

pub const blue_050 = Color(r: 240, g: 240, b: 251, a: 1.0)

pub const blue_100 = Color(r: 224, g: 225, b: 250, a: 1.0)

pub const blue_150 = Color(r: 208, g: 210, b: 250, a: 1.0)

pub const blue_200 = Color(r: 191, g: 195, b: 250, a: 1.0)

pub const blue_250 = Color(r: 174, g: 181, b: 251, a: 1.0)

pub const blue_300 = Color(r: 156, g: 167, b: 250, a: 1.0)

pub const blue_350 = Color(r: 137, g: 153, b: 249, a: 1.0)

pub const blue_400 = Color(r: 116, g: 139, b: 248, a: 1.0)

pub const blue_450 = Color(r: 92, g: 126, b: 248, a: 1.0)

pub const blue_500 = Color(r: 60, g: 113, b: 247, a: 1.0)

pub const blue_550 = Color(r: 32, g: 96, b: 223, a: 1.0)

pub const blue_600 = Color(r: 29, g: 89, b: 208, a: 1.0)

pub const blue_650 = Color(r: 24, g: 78, b: 184, a: 1.0)

pub const blue_700 = Color(r: 19, g: 67, b: 160, a: 1.0)

pub const blue_750 = Color(r: 15, g: 56, b: 136, a: 1.0)

pub const blue_800 = Color(r: 15, g: 45, b: 112, a: 1.0)

pub const blue_850 = Color(r: 14, g: 35, b: 88, a: 1.0)

pub const blue_900 = Color(r: 12, g: 26, b: 65, a: 1.0)

pub const blue_950 = Color(r: 8, g: 15, b: 45, a: 1.0)

pub const cyan = Color(r: 4, g: 120, b: 120, a: 1.0)

pub const cyan_050 = Color(r: 195, g: 252, b: 250, a: 1.0)

pub const cyan_100 = Color(r: 88, g: 250, b: 249, a: 1.0)

pub const cyan_150 = Color(r: 61, g: 236, b: 235, a: 1.0)

pub const cyan_200 = Color(r: 37, g: 221, b: 221, a: 1.0)

pub const cyan_250 = Color(r: 12, g: 206, b: 206, a: 1.0)

pub const cyan_300 = Color(r: 10, g: 194, b: 194, a: 1.0)

pub const cyan_350 = Color(r: 10, g: 177, b: 177, a: 1.0)

pub const cyan_400 = Color(r: 5, g: 162, b: 162, a: 1.0)

pub const cyan_450 = Color(r: 5, g: 148, b: 148, a: 1.0)

pub const cyan_500 = Color(r: 5, g: 134, b: 134, a: 1.0)

pub const cyan_550 = Color(r: 4, g: 120, b: 120, a: 1.0)

pub const cyan_600 = Color(r: 4, g: 106, b: 106, a: 1.0)

pub const cyan_650 = Color(r: 2, g: 93, b: 93, a: 1.0)

pub const cyan_700 = Color(r: 1, g: 80, b: 80, a: 1.0)

pub const cyan_750 = Color(r: 1, g: 67, b: 67, a: 1.0)

pub const cyan_800 = Color(r: 4, g: 55, b: 55, a: 1.0)

pub const cyan_850 = Color(r: 5, g: 43, b: 43, a: 1.0)

pub const cyan_900 = Color(r: 5, g: 31, b: 31, a: 1.0)

pub const cyan_950 = Color(r: 4, g: 20, b: 19, a: 1.0)

pub const fuchsia = Color(r: 193, g: 32, b: 139, a: 1.0)

pub const fuchsia_050 = Color(r: 251, g: 237, b: 244, a: 1.0)

pub const fuchsia_100 = Color(r: 249, g: 218, b: 234, a: 1.0)

pub const fuchsia_150 = Color(r: 249, g: 198, b: 225, a: 1.0)

pub const fuchsia_200 = Color(r: 249, g: 177, b: 216, a: 1.0)

pub const fuchsia_250 = Color(r: 250, g: 154, b: 207, a: 1.0)

pub const fuchsia_300 = Color(r: 249, g: 131, b: 199, a: 1.0)

pub const fuchsia_350 = Color(r: 248, g: 105, b: 191, a: 1.0)

pub const fuchsia_400 = Color(r: 247, g: 72, b: 183, a: 1.0)

pub const fuchsia_450 = Color(r: 237, g: 42, b: 172, a: 1.0)

pub const fuchsia_500 = Color(r: 217, g: 38, b: 157, a: 1.0)

pub const fuchsia_550 = Color(r: 193, g: 32, b: 139, a: 1.0)

pub const fuchsia_600 = Color(r: 172, g: 28, b: 124, a: 1.0)

pub const fuchsia_650 = Color(r: 152, g: 23, b: 109, a: 1.0)

pub const fuchsia_700 = Color(r: 132, g: 19, b: 94, a: 1.0)

pub const fuchsia_750 = Color(r: 112, g: 14, b: 79, a: 1.0)

pub const fuchsia_800 = Color(r: 92, g: 13, b: 65, a: 1.0)

pub const fuchsia_850 = Color(r: 72, g: 11, b: 51, a: 1.0)

pub const fuchsia_900 = Color(r: 54, g: 9, b: 37, a: 1.0)

pub const fuchsia_950 = Color(r: 35, g: 5, b: 24, a: 1.0)

pub const green = Color(r: 57, g: 135, b: 18, a: 1.0)

pub const green_050 = Color(r: 215, g: 251, b: 193, a: 1.0)

pub const green_100 = Color(r: 149, g: 251, b: 98, a: 1.0)

pub const green_150 = Color(r: 119, g: 239, b: 61, a: 1.0)

pub const green_200 = Color(r: 98, g: 217, b: 38, a: 1.0)

pub const green_250 = Color(r: 93, g: 209, b: 33, a: 1.0)

pub const green_300 = Color(r: 85, g: 194, b: 30, a: 1.0)

pub const green_350 = Color(r: 78, g: 179, b: 27, a: 1.0)

pub const green_400 = Color(r: 71, g: 164, b: 23, a: 1.0)

pub const green_450 = Color(r: 64, g: 150, b: 20, a: 1.0)

pub const green_500 = Color(r: 57, g: 135, b: 18, a: 1.0)

pub const green_550 = Color(r: 51, g: 121, b: 15, a: 1.0)

pub const green_600 = Color(r: 44, g: 108, b: 12, a: 1.0)

pub const green_650 = Color(r: 38, g: 94, b: 9, a: 1.0)

pub const green_700 = Color(r: 32, g: 81, b: 7, a: 1.0)

pub const green_750 = Color(r: 26, g: 68, b: 5, a: 1.0)

pub const green_800 = Color(r: 23, g: 56, b: 6, a: 1.0)

pub const green_850 = Color(r: 21, g: 43, b: 7, a: 1.0)

pub const green_900 = Color(r: 19, g: 31, b: 7, a: 1.0)

pub const green_950 = Color(r: 11, g: 19, b: 5, a: 1.0)

pub const grey = Color(r: 171, g: 171, b: 171, a: 1.0)

pub const grey_050 = Color(r: 241, g: 241, b: 241, a: 1.0)

pub const grey_100 = Color(r: 226, g: 226, b: 226, a: 1.0)

pub const grey_150 = Color(r: 212, g: 212, b: 212, a: 1.0)

pub const grey_200 = Color(r: 198, g: 198, b: 198, a: 1.0)

pub const grey_250 = Color(r: 185, g: 185, b: 185, a: 1.0)

pub const grey_300 = Color(r: 171, g: 171, b: 171, a: 1.0)

pub const grey_350 = Color(r: 158, g: 158, b: 158, a: 1.0)

pub const grey_400 = Color(r: 145, g: 145, b: 145, a: 1.0)

pub const grey_450 = Color(r: 128, g: 128, b: 128, a: 1.0)

pub const grey_500 = Color(r: 119, g: 119, b: 119, a: 1.0)

pub const grey_550 = Color(r: 106, g: 106, b: 106, a: 1.0)

pub const grey_600 = Color(r: 94, g: 94, b: 94, a: 1.0)

pub const grey_650 = Color(r: 82, g: 82, b: 82, a: 1.0)

pub const grey_700 = Color(r: 71, g: 71, b: 71, a: 1.0)

pub const grey_750 = Color(r: 59, g: 59, b: 59, a: 1.0)

pub const grey_800 = Color(r: 48, g: 48, b: 48, a: 1.0)

pub const grey_850 = Color(r: 38, g: 38, b: 38, a: 1.0)

pub const grey_900 = Color(r: 27, g: 27, b: 27, a: 1.0)

pub const grey_950 = Color(r: 17, g: 17, b: 17, a: 1.0)

pub const indigo = Color(r: 82, g: 78, b: 210, a: 1.0)

pub const indigo_050 = Color(r: 242, g: 240, b: 249, a: 1.0)

pub const indigo_100 = Color(r: 229, g: 224, b: 244, a: 1.0)

pub const indigo_150 = Color(r: 216, g: 208, b: 241, a: 1.0)

pub const indigo_200 = Color(r: 202, g: 193, b: 238, a: 1.0)

pub const indigo_250 = Color(r: 189, g: 178, b: 236, a: 1.0)

pub const indigo_300 = Color(r: 176, g: 163, b: 232, a: 1.0)

pub const indigo_350 = Color(r: 162, g: 148, b: 229, a: 1.0)

pub const indigo_400 = Color(r: 148, g: 134, b: 225, a: 1.0)

pub const indigo_450 = Color(r: 133, g: 119, b: 221, a: 1.0)

pub const indigo_500 = Color(r: 117, g: 105, b: 218, a: 1.0)

pub const indigo_550 = Color(r: 101, g: 92, b: 214, a: 1.0)

pub const indigo_600 = Color(r: 82, g: 78, b: 210, a: 1.0)

pub const indigo_650 = Color(r: 64, g: 64, b: 191, a: 1.0)

pub const indigo_700 = Color(r: 56, g: 56, b: 171, a: 1.0)

pub const indigo_750 = Color(r: 47, g: 47, b: 146, a: 1.0)

pub const indigo_800 = Color(r: 39, g: 38, b: 120, a: 1.0)

pub const indigo_850 = Color(r: 31, g: 30, b: 94, a: 1.0)

pub const indigo_900 = Color(r: 24, g: 21, b: 70, a: 1.0)

pub const indigo_950 = Color(r: 17, g: 11, b: 49, a: 1.0)

pub const jade = Color(r: 0, g: 122, b: 80, a: 1.0)

pub const jade_050 = Color(r: 203, g: 252, b: 225, a: 1.0)

pub const jade_100 = Color(r: 112, g: 252, b: 186, a: 1.0)

pub const jade_150 = Color(r: 57, g: 241, b: 166, a: 1.0)

pub const jade_200 = Color(r: 33, g: 226, b: 153, a: 1.0)

pub const jade_250 = Color(r: 0, g: 204, b: 136, a: 1.0)

pub const jade_300 = Color(r: 0, g: 196, b: 130, a: 1.0)

pub const jade_350 = Color(r: 0, g: 180, b: 120, a: 1.0)

pub const jade_400 = Color(r: 0, g: 166, b: 110, a: 1.0)

pub const jade_450 = Color(r: 2, g: 151, b: 100, a: 1.0)

pub const jade_500 = Color(r: 0, g: 137, b: 90, a: 1.0)

pub const jade_550 = Color(r: 0, g: 122, b: 80, a: 1.0)

pub const jade_600 = Color(r: 0, g: 109, b: 70, a: 1.0)

pub const jade_650 = Color(r: 0, g: 95, b: 61, a: 1.0)

pub const jade_700 = Color(r: 1, g: 82, b: 52, a: 1.0)

pub const jade_750 = Color(r: 0, g: 69, b: 43, a: 1.0)

pub const jade_800 = Color(r: 3, g: 56, b: 35, a: 1.0)

pub const jade_850 = Color(r: 4, g: 44, b: 27, a: 1.0)

pub const jade_900 = Color(r: 5, g: 32, b: 20, a: 1.0)

pub const jade_950 = Color(r: 4, g: 20, b: 12, a: 1.0)

pub const lime = Color(r: 165, g: 214, b: 1, a: 1.0)

pub const lime_050 = Color(r: 222, g: 252, b: 133, a: 1.0)

pub const lime_100 = Color(r: 193, g: 243, b: 53, a: 1.0)

pub const lime_150 = Color(r: 178, g: 229, b: 26, a: 1.0)

pub const lime_200 = Color(r: 165, g: 214, b: 1, a: 1.0)

pub const lime_250 = Color(r: 153, g: 200, b: 1, a: 1.0)

pub const lime_300 = Color(r: 142, g: 185, b: 1, a: 1.0)

pub const lime_350 = Color(r: 130, g: 171, b: 0, a: 1.0)

pub const lime_400 = Color(r: 119, g: 156, b: 0, a: 1.0)

pub const lime_450 = Color(r: 108, g: 143, b: 0, a: 1.0)

pub const lime_500 = Color(r: 98, g: 129, b: 0, a: 1.0)

pub const lime_550 = Color(r: 87, g: 116, b: 0, a: 1.0)

pub const lime_600 = Color(r: 77, g: 102, b: 0, a: 1.0)

pub const lime_650 = Color(r: 67, g: 90, b: 0, a: 1.0)

pub const lime_700 = Color(r: 57, g: 77, b: 0, a: 1.0)

pub const lime_750 = Color(r: 48, g: 65, b: 0, a: 1.0)

pub const lime_800 = Color(r: 39, g: 53, b: 0, a: 1.0)

pub const lime_850 = Color(r: 32, g: 41, b: 2, a: 1.0)

pub const lime_900 = Color(r: 25, g: 29, b: 3, a: 1.0)

pub const lime_950 = Color(r: 16, g: 18, b: 3, a: 1.0)

pub const orange = Color(r: 210, g: 67, b: 23, a: 1.0)

pub const orange_050 = Color(r: 250, g: 238, b: 234, a: 1.0)

pub const orange_100 = Color(r: 249, g: 220, b: 210, a: 1.0)

pub const orange_150 = Color(r: 248, g: 202, b: 185, a: 1.0)

pub const orange_200 = Color(r: 248, g: 183, b: 159, a: 1.0)

pub const orange_250 = Color(r: 248, g: 162, b: 131, a: 1.0)

pub const orange_300 = Color(r: 246, g: 142, b: 104, a: 1.0)

pub const orange_350 = Color(r: 245, g: 107, b: 61, a: 1.0)

pub const orange_400 = Color(r: 244, g: 93, b: 44, a: 1.0)

pub const orange_450 = Color(r: 231, g: 75, b: 26, a: 1.0)

pub const orange_500 = Color(r: 210, g: 67, b: 23, a: 1.0)

pub const orange_550 = Color(r: 189, g: 60, b: 19, a: 1.0)

pub const orange_600 = Color(r: 168, g: 52, b: 16, a: 1.0)

pub const orange_650 = Color(r: 148, g: 45, b: 13, a: 1.0)

pub const orange_700 = Color(r: 127, g: 39, b: 11, a: 1.0)

pub const orange_750 = Color(r: 107, g: 34, b: 10, a: 1.0)

pub const orange_800 = Color(r: 86, g: 30, b: 10, a: 1.0)

pub const orange_850 = Color(r: 65, g: 26, b: 10, a: 1.0)

pub const orange_900 = Color(r: 45, g: 21, b: 9, a: 1.0)

pub const orange_950 = Color(r: 27, g: 13, b: 6, a: 1.0)

pub const pink = Color(r: 217, g: 38, b: 98, a: 1.0)

pub const pink_050 = Color(r: 251, g: 237, b: 239, a: 1.0)

pub const pink_100 = Color(r: 249, g: 219, b: 223, a: 1.0)

pub const pink_150 = Color(r: 249, g: 200, b: 206, a: 1.0)

pub const pink_200 = Color(r: 249, g: 180, b: 190, a: 1.0)

pub const pink_250 = Color(r: 249, g: 158, b: 174, a: 1.0)

pub const pink_300 = Color(r: 248, g: 136, b: 158, a: 1.0)

pub const pink_350 = Color(r: 247, g: 112, b: 142, a: 1.0)

pub const pink_400 = Color(r: 246, g: 84, b: 126, a: 1.0)

pub const pink_450 = Color(r: 244, g: 44, b: 111, a: 1.0)

pub const pink_500 = Color(r: 217, g: 38, b: 98, a: 1.0)

pub const pink_550 = Color(r: 199, g: 34, b: 89, a: 1.0)

pub const pink_600 = Color(r: 178, g: 30, b: 79, a: 1.0)

pub const pink_650 = Color(r: 157, g: 25, b: 69, a: 1.0)

pub const pink_700 = Color(r: 136, g: 20, b: 59, a: 1.0)

pub const pink_750 = Color(r: 116, g: 15, b: 49, a: 1.0)

pub const pink_800 = Color(r: 95, g: 14, b: 40, a: 1.0)

pub const pink_850 = Color(r: 75, g: 12, b: 31, a: 1.0)

pub const pink_900 = Color(r: 56, g: 9, b: 22, a: 1.0)

pub const pink_950 = Color(r: 37, g: 6, b: 12, a: 1.0)

pub const pumpkin = Color(r: 255, g: 149, b: 0, a: 1.0)

pub const pumpkin_050 = Color(r: 252, g: 238, b: 227, a: 1.0)

pub const pumpkin_100 = Color(r: 252, g: 220, b: 193, a: 1.0)

pub const pumpkin_150 = Color(r: 252, g: 202, b: 155, a: 1.0)

pub const pumpkin_200 = Color(r: 254, g: 182, b: 112, a: 1.0)

pub const pumpkin_250 = Color(r: 255, g: 162, b: 58, a: 1.0)

pub const pumpkin_300 = Color(r: 255, g: 149, b: 0, a: 1.0)

pub const pumpkin_350 = Color(r: 228, g: 133, b: 0, a: 1.0)

pub const pumpkin_400 = Color(r: 210, g: 122, b: 1, a: 1.0)

pub const pumpkin_450 = Color(r: 191, g: 110, b: 0, a: 1.0)

pub const pumpkin_500 = Color(r: 173, g: 100, b: 0, a: 1.0)

pub const pumpkin_550 = Color(r: 156, g: 89, b: 0, a: 1.0)

pub const pumpkin_600 = Color(r: 139, g: 79, b: 0, a: 1.0)

pub const pumpkin_650 = Color(r: 122, g: 68, b: 0, a: 1.0)

pub const pumpkin_700 = Color(r: 105, g: 58, b: 0, a: 1.0)

pub const pumpkin_750 = Color(r: 89, g: 49, b: 0, a: 1.0)

pub const pumpkin_800 = Color(r: 72, g: 40, b: 2, a: 1.0)

pub const pumpkin_850 = Color(r: 55, g: 32, b: 4, a: 1.0)

pub const pumpkin_900 = Color(r: 39, g: 24, b: 5, a: 1.0)

pub const pumpkin_950 = Color(r: 24, g: 15, b: 4, a: 1.0)

pub const purple = Color(r: 146, g: 54, b: 164, a: 1.0)

pub const purple_050 = Color(r: 248, g: 238, b: 249, a: 1.0)

pub const purple_100 = Color(r: 242, g: 220, b: 244, a: 1.0)

pub const purple_150 = Color(r: 237, g: 201, b: 241, a: 1.0)

pub const purple_200 = Color(r: 231, g: 182, b: 238, a: 1.0)

pub const purple_250 = Color(r: 226, g: 163, b: 235, a: 1.0)

pub const purple_300 = Color(r: 219, g: 144, b: 232, a: 1.0)

pub const purple_350 = Color(r: 212, g: 125, b: 228, a: 1.0)

pub const purple_400 = Color(r: 205, g: 104, b: 224, a: 1.0)

pub const purple_450 = Color(r: 198, g: 82, b: 220, a: 1.0)

pub const purple_500 = Color(r: 182, g: 69, b: 205, a: 1.0)

pub const purple_550 = Color(r: 170, g: 64, b: 191, a: 1.0)

pub const purple_600 = Color(r: 146, g: 54, b: 164, a: 1.0)

pub const purple_650 = Color(r: 128, g: 46, b: 144, a: 1.0)

pub const purple_700 = Color(r: 111, g: 39, b: 125, a: 1.0)

pub const purple_750 = Color(r: 94, g: 32, b: 107, a: 1.0)

pub const purple_800 = Color(r: 77, g: 26, b: 87, a: 1.0)

pub const purple_850 = Color(r: 61, g: 21, b: 69, a: 1.0)

pub const purple_900 = Color(r: 45, g: 15, b: 51, a: 1.0)

pub const purple_950 = Color(r: 30, g: 8, b: 32, a: 1.0)

pub const red = Color(r: 197, g: 47, b: 33, a: 1.0)

pub const red_050 = Color(r: 250, g: 238, b: 235, a: 1.0)

pub const red_100 = Color(r: 248, g: 220, b: 214, a: 1.0)

pub const red_150 = Color(r: 246, g: 202, b: 191, a: 1.0)

pub const red_200 = Color(r: 245, g: 183, b: 168, a: 1.0)

pub const red_250 = Color(r: 245, g: 163, b: 144, a: 1.0)

pub const red_300 = Color(r: 243, g: 143, b: 121, a: 1.0)

pub const red_350 = Color(r: 241, g: 121, b: 97, a: 1.0)

pub const red_400 = Color(r: 240, g: 96, b: 72, a: 1.0)

pub const red_450 = Color(r: 238, g: 64, b: 46, a: 1.0)

pub const red_500 = Color(r: 217, g: 53, b: 38, a: 1.0)

pub const red_550 = Color(r: 197, g: 47, b: 33, a: 1.0)

pub const red_600 = Color(r: 175, g: 41, b: 29, a: 1.0)

pub const red_650 = Color(r: 155, g: 35, b: 24, a: 1.0)

pub const red_700 = Color(r: 134, g: 29, b: 19, a: 1.0)

pub const red_750 = Color(r: 114, g: 23, b: 15, a: 1.0)

pub const red_800 = Color(r: 92, g: 22, b: 13, a: 1.0)

pub const red_850 = Color(r: 69, g: 21, b: 12, a: 1.0)

pub const red_900 = Color(r: 48, g: 19, b: 10, a: 1.0)

pub const red_950 = Color(r: 28, g: 13, b: 6, a: 1.0)

pub const sand = Color(r: 204, g: 198, b: 180, a: 1.0)

pub const sand_050 = Color(r: 242, g: 240, b: 236, a: 1.0)

pub const sand_100 = Color(r: 232, g: 226, b: 210, a: 1.0)

pub const sand_150 = Color(r: 218, g: 212, b: 194, a: 1.0)

pub const sand_200 = Color(r: 204, g: 198, b: 180, a: 1.0)

pub const sand_250 = Color(r: 190, g: 184, b: 167, a: 1.0)

pub const sand_300 = Color(r: 176, g: 171, b: 155, a: 1.0)

pub const sand_350 = Color(r: 163, g: 158, b: 143, a: 1.0)

pub const sand_400 = Color(r: 149, g: 144, b: 130, a: 1.0)

pub const sand_450 = Color(r: 136, g: 131, b: 119, a: 1.0)

pub const sand_500 = Color(r: 123, g: 119, b: 107, a: 1.0)

pub const sand_550 = Color(r: 110, g: 106, b: 96, a: 1.0)

pub const sand_600 = Color(r: 97, g: 94, b: 85, a: 1.0)

pub const sand_650 = Color(r: 85, g: 82, b: 74, a: 1.0)

pub const sand_700 = Color(r: 73, g: 70, b: 63, a: 1.0)

pub const sand_750 = Color(r: 61, g: 59, b: 53, a: 1.0)

pub const sand_800 = Color(r: 50, g: 48, b: 43, a: 1.0)

pub const sand_850 = Color(r: 39, g: 38, b: 34, a: 1.0)

pub const sand_900 = Color(r: 28, g: 27, b: 25, a: 1.0)

pub const sand_950 = Color(r: 17, g: 17, b: 16, a: 1.0)

pub const slate = Color(r: 82, g: 95, b: 122, a: 1.0)

pub const slate_050 = Color(r: 239, g: 241, b: 244, a: 1.0)

pub const slate_100 = Color(r: 223, g: 227, b: 235, a: 1.0)

pub const slate_150 = Color(r: 207, g: 213, b: 226, a: 1.0)

pub const slate_200 = Color(r: 191, g: 199, b: 217, a: 1.0)

pub const slate_250 = Color(r: 176, g: 185, b: 208, a: 1.0)

pub const slate_300 = Color(r: 160, g: 172, b: 199, a: 1.0)

pub const slate_350 = Color(r: 144, g: 158, b: 190, a: 1.0)

pub const slate_400 = Color(r: 129, g: 145, b: 181, a: 1.0)

pub const slate_450 = Color(r: 115, g: 133, b: 169, a: 1.0)

pub const slate_500 = Color(r: 104, g: 120, b: 153, a: 1.0)

pub const slate_550 = Color(r: 93, g: 107, b: 137, a: 1.0)

pub const slate_600 = Color(r: 82, g: 95, b: 122, a: 1.0)

pub const slate_650 = Color(r: 72, g: 83, b: 107, a: 1.0)

pub const slate_700 = Color(r: 61, g: 71, b: 92, a: 1.0)

pub const slate_750 = Color(r: 51, g: 60, b: 78, a: 1.0)

pub const slate_800 = Color(r: 42, g: 49, b: 64, a: 1.0)

pub const slate_850 = Color(r: 32, g: 38, b: 50, a: 1.0)

pub const slate_900 = Color(r: 24, g: 28, b: 37, a: 1.0)

pub const slate_950 = Color(r: 14, g: 17, b: 24, a: 1.0)

pub const violet = Color(r: 117, g: 64, b: 191, a: 1.0)

pub const violet_050 = Color(r: 243, g: 239, b: 247, a: 1.0)

pub const violet_100 = Color(r: 232, g: 223, b: 242, a: 1.0)

pub const violet_150 = Color(r: 222, g: 207, b: 237, a: 1.0)

pub const violet_200 = Color(r: 211, g: 191, b: 232, a: 1.0)

pub const violet_250 = Color(r: 201, g: 175, b: 228, a: 1.0)

pub const violet_300 = Color(r: 189, g: 159, b: 223, a: 1.0)

pub const violet_350 = Color(r: 178, g: 144, b: 217, a: 1.0)

pub const violet_400 = Color(r: 167, g: 128, b: 212, a: 1.0)

pub const violet_450 = Color(r: 155, g: 113, b: 207, a: 1.0)

pub const violet_500 = Color(r: 144, g: 98, b: 202, a: 1.0)

pub const violet_550 = Color(r: 131, g: 82, b: 197, a: 1.0)

pub const violet_600 = Color(r: 117, g: 64, b: 191, a: 1.0)

pub const violet_650 = Color(r: 105, g: 53, b: 179, a: 1.0)

pub const violet_700 = Color(r: 91, g: 45, b: 156, a: 1.0)

pub const violet_750 = Color(r: 77, g: 37, b: 133, a: 1.0)

pub const violet_800 = Color(r: 63, g: 30, b: 109, a: 1.0)

pub const violet_850 = Color(r: 50, g: 24, b: 86, a: 1.0)

pub const violet_900 = Color(r: 37, g: 17, b: 64, a: 1.0)

pub const violet_950 = Color(r: 25, g: 9, b: 40, a: 1.0)

pub const yellow = Color(r: 242, g: 223, b: 13, a: 1.0)

pub const yellow_050 = Color(r: 253, g: 241, b: 180, a: 1.0)

pub const yellow_100 = Color(r: 242, g: 223, b: 13, a: 1.0)

pub const yellow_150 = Color(r: 232, g: 214, b: 0, a: 1.0)

pub const yellow_200 = Color(r: 217, g: 200, b: 0, a: 1.0)

pub const yellow_250 = Color(r: 202, g: 186, b: 1, a: 1.0)

pub const yellow_300 = Color(r: 187, g: 172, b: 0, a: 1.0)

pub const yellow_350 = Color(r: 173, g: 159, b: 0, a: 1.0)

pub const yellow_400 = Color(r: 158, g: 146, b: 0, a: 1.0)

pub const yellow_450 = Color(r: 144, g: 133, b: 1, a: 1.0)

pub const yellow_500 = Color(r: 130, g: 120, b: 0, a: 1.0)

pub const yellow_550 = Color(r: 117, g: 107, b: 0, a: 1.0)

pub const yellow_600 = Color(r: 104, g: 95, b: 0, a: 1.0)

pub const yellow_650 = Color(r: 91, g: 83, b: 0, a: 1.0)

pub const yellow_700 = Color(r: 78, g: 71, b: 0, a: 1.0)

pub const yellow_750 = Color(r: 66, g: 60, b: 0, a: 1.0)

pub const yellow_800 = Color(r: 54, g: 49, b: 0, a: 1.0)

pub const yellow_850 = Color(r: 43, g: 38, b: 0, a: 1.0)

pub const yellow_900 = Color(r: 31, g: 28, b: 2, a: 1.0)

pub const yellow_950 = Color(r: 20, g: 17, b: 3, a: 1.0)

pub const zinc = Color(r: 100, g: 107, b: 121, a: 1.0)

pub const zinc_050 = Color(r: 240, g: 241, b: 243, a: 1.0)

pub const zinc_100 = Color(r: 224, g: 227, b: 231, a: 1.0)

pub const zinc_150 = Color(r: 209, g: 213, b: 219, a: 1.0)

pub const zinc_200 = Color(r: 194, g: 199, b: 208, a: 1.0)

pub const zinc_250 = Color(r: 179, g: 185, b: 197, a: 1.0)

pub const zinc_300 = Color(r: 164, g: 172, b: 186, a: 1.0)

pub const zinc_350 = Color(r: 150, g: 158, b: 175, a: 1.0)

pub const zinc_400 = Color(r: 136, g: 145, b: 164, a: 1.0)

pub const zinc_450 = Color(r: 123, g: 132, b: 149, a: 1.0)

pub const zinc_500 = Color(r: 111, g: 120, b: 135, a: 1.0)

pub const zinc_550 = Color(r: 100, g: 107, b: 121, a: 1.0)

pub const zinc_600 = Color(r: 92, g: 99, b: 112, a: 1.0)

pub const zinc_650 = Color(r: 77, g: 83, b: 94, a: 1.0)

pub const zinc_700 = Color(r: 66, g: 71, b: 81, a: 1.0)

pub const zinc_750 = Color(r: 55, g: 60, b: 68, a: 1.0)

pub const zinc_800 = Color(r: 45, g: 49, b: 56, a: 1.0)

pub const zinc_850 = Color(r: 35, g: 38, b: 44, a: 1.0)

pub const zinc_900 = Color(r: 25, g: 28, b: 32, a: 1.0)

pub const zinc_950 = Color(r: 15, g: 17, b: 20, a: 1.0)
