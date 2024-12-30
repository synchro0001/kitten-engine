import gleam/bool.{guard}
import gleam/int
import gleam/list
import gleam/pair
import kitten/canvas
import kitten/color.{type Color}
import kitten/draw
import kitten/mouse
import kitten/simulate
import kitten/sound.{type Sound}
import kitten/vec2.{type Vec2, Vec2}

pub fn main() {
  canvas.start_window(init, update, view, "canvas", 1920.0, 1080.0, [], [
    "hit.js",
  ])
}

type Model {
  Model(
    player: PlayerState,
    direction: Vec2,
    balls: List(Ball),
    blocks: List(Block),
    cooldown: Int,
    palette: Palette,
    hit_sound: Sound,
  )
}

type PlayerState {
  Idle
  Shooting
  Collecting
  HasWon
}

type Block {
  Block(pos: Vec2, is_showing: Bool, durability: Int)
}

type Ball {
  Ball(pos: Vec2, vel: Vec2, state: BallState)
}

type BallState {
  InAir
  OnGround
  HasLanded
}

type Palette {
  Palette(dur10: Color, dur20: Color, dur30: Color, dur40: Color, dur50: Color)
}

const ball_count = 30

const block_count = 10

const block_size = Vec2(40.0, 40.0)

const ball_size = Vec2(16.0, 16.0)

fn init() {
  let balls =
    list.range(0, ball_count - 1)
    |> list.map(fn(_) { Ball(Vec2(0.0, -300.0), Vec2(0.0, 0.0), OnGround) })

  let blocks =
    list.range(0, block_count - 1)
    |> list.map(fn(_) { #(int.random(10), int.random(10), int.random(49) + 1) })
    |> list.unique
    |> list.map(fn(block_prototype) {
      let #(x, y, durability) = block_prototype
      Block(
        Vec2(
          int.to_float(x - 5) *. block_size.x,
          int.to_float(y - 5) *. block_size.y,
        ),
        True,
        durability,
      )
    })

  let assert Ok(dur10) = color.from_hsl(0, 90, 50)
  let assert Ok(dur20) = color.from_hsl(40, 90, 50)
  let assert Ok(dur30) = color.from_hsl(80, 90, 50)
  let assert Ok(dur40) = color.from_hsl(120, 90, 50)
  let assert Ok(dur50) = color.from_hsl(160, 90, 50)

  let palette = Palette(dur10, dur20, dur30, dur40, dur50)

  let assert Ok(hit_sound) = sound.new(0)

  Model(Idle, Vec2(0.0, 0.0), balls, blocks, 0, palette, hit_sound)
}

fn update(model: Model) {
  case model.player {
    Idle ->
      case
        list.all(model.blocks, fn(block) { !block.is_showing }),
        mouse.was_released(mouse.LMB)
        && simulate.is_within(mouse.pos(), Vec2(0.0, 0.0), Vec2(620.0, 620.0))
      {
        True, _ -> Model(..model, player: HasWon)
        _, True -> {
          let assert Ok(first_ball) = model.balls |> list.first
          let direction =
            vec2.subtract(mouse.pos(), first_ball.pos)
            |> vec2.set_length(5.0)
          Model(..model, player: Shooting, direction:)
        }
        _, _ -> model
      }
    Shooting -> {
      let assert Ok(last_ball) = list.last(model.balls)
      case last_ball.state == InAir {
        True -> Model(..model, player: Collecting)
        False -> {
          let #(balls, blocks) =
            model.balls
            |> list.map_fold(True, fn(is_first, ball) {
              case model.cooldown >= 4, is_first, ball.state {
                False, _, _ -> #(False, ball)
                _, True, OnGround -> #(
                  False,
                  Ball(..ball, vel: model.direction, state: InAir),
                )
                _, True, _ -> #(True, ball)
                _, _, _ -> #(False, ball)
              }
            })
            |> pair.second
            |> list.map(fn(ball) {
              Ball(..ball, pos: simulate.move(ball.pos, ball.vel))
            })
            |> simulate(model.blocks, model.hit_sound)
          Model(..model, balls:, blocks:, cooldown: { model.cooldown + 1 } % 5)
        }
      }
    }
    Collecting ->
      case list.all(model.balls, fn(ball) { ball.state == HasLanded }) {
        True -> {
          let assert Ok(ball_pos) =
            model.balls
            |> list.map(fn(ball) { ball.pos })
            |> list.first
          let balls =
            model.balls
            |> list.map(fn(ball) {
              Ball(..ball, pos: ball_pos, state: OnGround)
            })
          Model(..model, balls:, player: Idle)
        }
        False -> {
          let #(balls, blocks) =
            model.balls
            |> list.map(fn(ball) {
              Ball(..ball, pos: simulate.move(ball.pos, ball.vel))
            })
            |> simulate(model.blocks, model.hit_sound)
          Model(..model, balls:, blocks:)
        }
      }
    HasWon -> model
  }
}

fn simulate(
  balls: List(Ball),
  blocks: List(Block),
  hit_sound: Sound,
) -> #(List(Ball), List(Block)) {
  let #(blocks, balls) =
    balls
    |> list.map_fold(blocks, fn(blocks, ball) {
      list.map_fold(blocks, ball, fn(ball, block) {
        use <- guard(!block.is_showing, return: #(ball, block))
        let block_durability = case
          simulate.is_overlapping(ball.pos, ball_size, block.pos, block_size)
        {
          True -> {
            sound.play(hit_sound)
            block.durability - 1
          }
          False -> block.durability
        }
        let block_is_showing = block_durability > 0
        use <- guard(!block_is_showing, return: #(
          ball,
          Block(..block, durability: 0, is_showing: False),
        ))
        let #(#(ball_pos, ball_vel), _) =
          simulate.collision(
            #(ball.pos, ball_size, ball.vel, 10.0),
            #(block.pos, block_size, Vec2(0.0, 0.0), 0.0),
            e: 1.0,
            f: 0.0,
          )
        #(
          Ball(..ball, pos: ball_pos, vel: ball_vel),
          Block(
            ..block,
            durability: block_durability,
            is_showing: block_is_showing,
          ),
        )
      })
      |> pair.swap
    })
  #(
    balls
      |> list.map(fn(ball) {
        let ball = case ball.pos.y <. -300.0 {
          True ->
            Ball(
              pos: ball.pos |> vec2.set_y(-300.0),
              vel: Vec2(0.0, 0.0),
              state: HasLanded,
            )
          False -> ball
        }
        let ball = case
          ball.pos.x >=. 300.0
          && ball.vel.x >. 0.0
          || ball.pos.x <=. -300.0
          && ball.vel.x <. 0.0
        {
          True -> {
            sound.play(hit_sound)
            Ball(..ball, vel: ball.vel |> vec2.multiply(Vec2(-1.0, 1.0)))
          }
          False -> ball
        }
        case ball.pos.y >=. 300.0 {
          True -> {
            sound.play(hit_sound)
            Ball(..ball, vel: ball.vel |> vec2.multiply(Vec2(1.0, -1.0)))
          }
          False -> ball
        }
      }),
    blocks,
  )
}

fn view(model: Model) {
  draw.context()
  |> draw.background(color.black)
  |> draw.set_camera_scale(1.5)
  |> draw.rect(Vec2(0.0, 313.0), Vec2(636.0, 10.0), color.slate_950)
  |> draw.rect(Vec2(0.0, -313.0), Vec2(636.0, 10.0), color.slate_950)
  |> draw.rect(Vec2(313.0, 0.0), Vec2(10.0, 620.0), color.slate_950)
  |> draw.rect(Vec2(-313.0, 0.0), Vec2(10.0, 620.0), color.slate_950)
  |> case model.player {
    HasWon -> draw.text(
      _,
      "You win!",
      Vec2(0.0, 0.0),
      200.0,
      300.0,
      "Arial",
      0.0,
      color.red_500,
    )
    _ -> list.fold(
      model.blocks,
      _,
      fn(ctx, block) {
        case block.is_showing {
          True -> {
            let dur = block.durability
            let color = case dur {
              _ if dur >= 40 -> model.palette.dur50
              _ if dur >= 30 -> model.palette.dur40
              _ if dur >= 20 -> model.palette.dur30
              _ if dur >= 10 -> model.palette.dur20
              _ -> model.palette.dur10
            }
            draw.rect(ctx, block.pos, block_size, color)
            |> draw.text(
              int.to_string(block.durability),
              block.pos |> vec2.subtract(Vec2(0.0, 7.0)),
              18.0,
              200.0,
              "Arial",
              0.0,
              color.black,
            )
          }
          False -> ctx
        }
      },
    )
  }
  |> list.fold(
    model.balls,
    _,
    fn(ctx, ball) {
      draw.circle(ctx, ball.pos, ball_size.x /. 2.0, color.white)
    },
  )
  Nil
}
