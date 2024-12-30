import gleam/float
import gleam/function.{identity as id}
import gleam/int
import kitten/canvas
import kitten/color
import kitten/draw
import kitten/key
import kitten/mouse
import kitten/simulate
import kitten/vec2.{type Vec2, Vec2}

pub fn main() {
  canvas.start_window(init, update, view, "canvas", 1920.0, 1080.0, [], [])
}

type Model {
  Model(
    ball_pos: Vec2,
    ball_vel: Vec2,
    player_y: Float,
    has_lost: Bool,
    score: Int,
  )
}

const player_x = -250.0

const player_vel = 5.0

const pad_width = 10.0

const pad_height = 50.0

const ball_radius = 8.0

fn init() {
  Model(
    ball_pos: Vec2(0.0, 0.0),
    ball_vel: Vec2(2.0, 0.8),
    player_y: 0.0,
    has_lost: False,
    score: 0,
  )
}

fn update(model: Model) {
  let player_y =
    model.player_y
    |> case
      key.is_down(key.A) || mouse.is_down(mouse.LMB) && mouse.pos().x <. 0.0
    {
      True -> float.add(_, player_vel)
      False -> id
    }
    |> case
      key.is_down(key.S) || mouse.is_down(mouse.LMB) && mouse.pos().x >. 0.0
    {
      True -> float.subtract(_, player_vel)
      False -> id
    }

  let Vec2(x, y) as ball_pos = simulate.move(model.ball_pos, model.ball_vel)

  let player_hit_ball =
    x <. player_x +. pad_width /. 2.0 +. ball_radius
    && y <. model.player_y +. pad_height /. 2.0
    && y >. model.player_y -. pad_height /. 2.0
    && model.ball_vel.x <. 0.0

  let score = case player_hit_ball && !model.has_lost {
    True -> model.score + 1
    False -> model.score
  }

  let ball_vel =
    model.ball_vel
    |> vec2.scale(1.01)
    |> vec2.clamp(Vec2(-5.0, -2.0), Vec2(5.0, 2.0))
    |> case
      player_hit_ball || x >. 0.0 -. player_x -. pad_width /. 2.0 -. ball_radius
    {
      True -> vec2.multiply(Vec2(-1.0, 1.0), _)
      False -> vec2.id
    }
    |> case y <. -300.0 || y >. 300.0 {
      True -> vec2.multiply(Vec2(1.0, -1.0), _)
      False -> vec2.id
    }

  case
    model.has_lost && { key.is_down(key.Space) || mouse.was_pressed(mouse.LMB) }
  {
    True -> init()
    False ->
      Model(
        ball_pos:,
        ball_vel:,
        player_y:,
        has_lost: x <. -265.0 || model.has_lost,
        score:,
      )
  }
}

fn view(model: Model) {
  case model.has_lost {
    True ->
      draw.context()
      |> draw.text(
        "You lost",
        Vec2(0.0, 0.0),
        100.0,
        300.0,
        "Arial",
        0.0,
        color.red_400,
      )
      |> draw.text(
        "Press space or anywhere",
        Vec2(0.0, -70.0),
        70.0,
        200.0,
        "Arial",
        0.0,
        color.red_400,
      )
      |> draw.text(
        "on the screen to continue",
        Vec2(0.0, -130.0),
        70.0,
        200.0,
        "Arial",
        0.0,
        color.red_400,
      )
    False ->
      draw.context()
      |> draw.rect(
        Vec2(player_x, model.player_y),
        Vec2(pad_width, pad_height),
        color.grey_100,
      )
      |> draw.rect(
        Vec2(0.0 -. player_x, model.ball_pos.y),
        Vec2(pad_width, pad_height),
        color.grey_100,
      )
      |> draw.circle(model.ball_pos, ball_radius, color.grey_100)
  }
  |> draw.background(color.slate_900)
  |> draw.text(
    "Score: " <> int.to_string(model.score),
    Vec2(0.0, -380.0),
    70.0,
    200.0,
    "Arial",
    0.0,
    color.grey_100,
  )
  |> draw.rect(
    Vec2(0.0, -305.0 -. ball_radius),
    Vec2(500.0, 10.0),
    color.grey_100,
  )
  |> draw.rect(
    Vec2(0.0, 305.0 +. ball_radius),
    Vec2(500.0, 10.0),
    color.grey_100,
  )
  |> draw.text(
    "PONG",
    Vec2(0.0, 350.0),
    100.0,
    300.0,
    "Arial",
    0.0,
    color.grey_100,
  )
  Nil
}
