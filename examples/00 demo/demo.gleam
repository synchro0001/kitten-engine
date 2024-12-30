import kitten/canvas
import kitten/color
import kitten/draw
import kitten/key
import kitten/vec2.{type Vec2, Vec2}

pub fn main() {
  canvas.start_window(init, update, view, "canvas", 1920.0, 1080.0, [], [])
}

type Model {
  Model(player_pos: Vec2)
}

const player_velocity = 5.0

const player_size = Vec2(80.0, 80.0)

fn init() {
  Model(player_pos: Vec2(0.0, 0.0))
}

fn update(model: Model) {
  let new_player_pos =
    model.player_pos
    |> case key.is_down(key.W) {
      True -> vec2.add(_, Vec2(0.0, player_velocity))
      _ -> vec2.id
    }
    |> case key.is_down(key.S) {
      True -> vec2.subtract(_, Vec2(0.0, player_velocity))
      _ -> vec2.id
    }
    |> case key.is_down(key.D) {
      True -> vec2.add(_, Vec2(player_velocity, 0.0))
      _ -> vec2.id
    }
    |> case key.is_down(key.A) {
      True -> vec2.subtract(_, Vec2(player_velocity, 0.0))
      _ -> vec2.id
    }
  Model(player_pos: new_player_pos)
}

fn view(model: Model) {
  draw.context()
  |> draw.background(color.black)
  |> draw.rect(model.player_pos, player_size, color.red)
  Nil
}
