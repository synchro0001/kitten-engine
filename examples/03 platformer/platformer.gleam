import gleam/bool.{guard}
import gleam/list
import kitten/canvas
import kitten/color
import kitten/draw.{type Texture}
import kitten/key
import kitten/mouse
import kitten/simulate
import kitten/vec2.{type Vec2, Vec2}

pub fn main() {
  canvas.start_window(
    init,
    update,
    view,
    "canvas",
    1920.0,
    1080.0,
    ["textures.png"],
    [],
  )
}

type Model {
  Menu(textures: Textures)
  Level1(player: Player, platforms: List(Platform), textures: Textures)
  Level2(player: Player, platforms: List(Platform), textures: Textures)
}

type Textures {
  Textures(block: Texture, player: Texture, checkpoint: Texture)
}

type Player {
  Player(pos: Vec2, vel: Vec2)
}

type Platform {
  StaticPlatform(pos: Vec2)
  MovingPlatform(pos: Vec2, dir: Float, point1: Vec2, point2: Vec2)
}

const player_velocity = 5.0

const player_size = Vec2(50.0, 50.0)

const platform_size = Vec2(100.0, 50.0)

const moving_platform_vel = 1.0

const checkpoint_size = Vec2(50.0, 50.0)

const lvl1_checkpoint = Vec2(-600.0, 100.0)

const lvl2_checkpoint = Vec2(800.0, 0.0)

fn init() {
  let assert Ok(block_texture) = draw.create_texture(0, 0, 0, 16, 8)
  let assert Ok(player_texture) = draw.create_texture(0, 16, 0, 8, 8)
  let assert Ok(checkpoint_texture) = draw.create_texture(0, 24, 0, 8, 8)
  Textures(block_texture, player_texture, checkpoint_texture)
  |> init_menu
}

fn init_menu(textures) {
  Menu(textures)
}

fn init_lvl1(textures) {
  Level1(
    Player(Vec2(-800.0, -300.0), Vec2(0.0, 0.0)),
    [
      Vec2(-800.0, -400.0),
      Vec2(-600.0, -400.0),
      Vec2(-400.0, -400.0),
      Vec2(-200.0, -400.0),
      Vec2(0.0, -400.0),
      Vec2(200.0, -400.0),
      Vec2(400.0, -250.0),
      Vec2(600.0, -50.0),
      Vec2(350.0, 150.0),
      Vec2(-50.0, 150.0),
      Vec2(-100.0, 350.0),
      Vec2(-400.0, 0.0),
    ]
      |> list.map(StaticPlatform),
    textures:,
  )
}

fn init_lvl2(textures) {
  Level2(
    Player(Vec2(-600.0, 50.0), Vec2(0.0, 0.0)),
    [
      StaticPlatform(Vec2(-600.0, 0.0)),
      MovingPlatform(
        Vec2(-200.0, 0.0),
        -1.0,
        Vec2(-300.0, 0.0),
        Vec2(-100.0, 0.0),
      ),
      MovingPlatform(Vec2(100.0, 0.0), -1.0, Vec2(0.0, 0.0), Vec2(200.0, 0.0)),
      MovingPlatform(Vec2(400.0, 0.0), -1.0, Vec2(300.0, 0.0), Vec2(500.0, 0.0)),
    ],
    textures,
  )
}

fn update(model: Model) {
  case model {
    Menu(textures) ->
      case
        mouse.is_down(mouse.LMB),
        simulate.is_within(mouse.pos(), Vec2(-200.0, 0.0), Vec2(300.0, 300.0)),
        simulate.is_within(mouse.pos(), Vec2(200.0, 0.0), Vec2(300.0, 300.0))
      {
        False, _, _ | True, False, False -> model
        True, True, _ -> init_lvl1(textures)
        True, _, True -> init_lvl2(textures)
      }
    Level1(player, platforms, textures) ->
      case
        simulate.is_overlapping(
          player.pos,
          player_size,
          lvl1_checkpoint,
          checkpoint_size,
        ),
        key.was_pressed(key.Escape)
      {
        _, True -> init_menu(textures)
        False, False -> update_lvl1(player, platforms, textures)
        True, False -> init_lvl2(textures)
      }
    Level2(player, platforms, textures) ->
      case
        simulate.is_overlapping(
          player.pos,
          player_size,
          lvl2_checkpoint,
          checkpoint_size,
        ),
        key.was_pressed(key.Escape)
      {
        _, True -> init_menu(textures)
        False, False -> update_lvl2(player, platforms, textures)
        True, False -> init_menu(textures)
      }
  }
}

fn update_lvl1(player: Player, platforms: List(Platform), textures) {
  use <- guard(player.pos.y <. -500.0, return: init_lvl1(textures))
  let player = Player(player.pos, update_player_vel(player, platforms))
  let platforms = update_platforms(platforms)
  let #(player, platforms) = update_collisions(player, platforms)
  let player = simulate.move(player.pos, player.vel) |> Player(player.vel)
  Level1(player:, platforms:, textures:)
}

fn update_lvl2(player: Player, platforms: List(Platform), textures) {
  use <- guard(player.pos.y <. -500.0, return: init_lvl2(textures))
  let player = Player(player.pos, update_player_vel(player, platforms))
  let platforms = update_platforms(platforms)
  let #(player, platforms) = update_collisions(player, platforms)
  let player = simulate.move(player.pos, player.vel) |> Player(player.vel)
  Level2(player:, platforms:, textures:)
}

fn update_player_vel(player: Player, platforms: List(Platform)) -> Vec2 {
  let player_is_grounded =
    list.any(platforms, fn(platform) {
      simulate.is_overlapping(
        player.pos
          |> vec2.subtract(Vec2(0.0, 1.0)),
        player_size |> vec2.scale(0.98),
        platform.pos,
        platform_size,
      )
    })
  let player_vel_x = case key.is_down(key.D), key.is_down(key.A) {
    True, _ -> player_velocity
    _, True -> 0.0 -. player_velocity
    False, False -> 0.0
  }
  Vec2(player_vel_x, player.vel.y)
  |> simulate.apply_gravity(10.0, 5.0)
  |> case key.was_pressed(key.W) && player_is_grounded {
    True -> simulate.apply_forces(_, 1.0, [Vec2(0.0, 15.0)])
    False -> vec2.id
  }
}

fn update_platforms(platforms: List(Platform)) {
  platforms
  |> list.map(fn(platform) {
    case platform {
      StaticPlatform(_) -> platform
      MovingPlatform(..) -> {
        let direction =
          vec2.subtract(platform.point2, platform.point1) |> vec2.normalize
        let dir = case
          platform.dir,
          vec2.dot_product(
            vec2.subtract(platform.point1, platform.point2),
            vec2.subtract(platform.pos, platform.point2),
          )
          <. 0.0,
          vec2.dot_product(
            vec2.subtract(platform.point2, platform.point1),
            vec2.subtract(platform.pos, platform.point1),
          )
          <. 0.0
        {
          1.0, True, _ | -1.0, _, True -> 0.0 -. platform.dir
          _, _, _ -> platform.dir
        }
        direction
        |> vec2.scale(dir *. moving_platform_vel)
        |> simulate.move(platform.pos, _)
        |> MovingPlatform(dir, platform.point1, platform.point2)
      }
    }
  })
}

fn update_collisions(player: Player, platforms: List(Platform)) {
  platforms
  |> list.map_fold(player, fn(player, platform) {
    let #(#(player_pos, player_vel), _) =
      simulate.collision(
        #(player.pos, player_size, player.vel, 1.0),
        #(platform.pos, platform_size, Vec2(0.0, 0.0), 0.0),
        e: 0.0,
        f: 0.0,
      )
    #(Player(player_pos, player_vel), platform)
  })
}

fn view(model: Model) {
  draw.context()
  |> draw.background(color.black)
  |> case model {
    Menu(_) -> fn(ctx) {
      draw.text(
        ctx,
        "MENU",
        Vec2(0.0, 200.0),
        100.0,
        300.0,
        "Arial",
        0.0,
        color.blue_250,
      )
      |> draw.text(
        "LEVEL 1",
        Vec2(-200.0, 0.0),
        80.0,
        200.0,
        "Arial",
        0.0,
        color.blue_250,
      )
      |> draw.text(
        "LEVEL 2",
        Vec2(200.0, 0.0),
        80.0,
        200.0,
        "Arial",
        0.0,
        color.blue_250,
      )
    }
    Level1(player, platforms, textures) -> fn(ctx) {
      draw.texture(ctx, textures.player, player.pos, player_size, 0.0)
      |> list.fold(
        platforms,
        _,
        fn(ctx, platform) {
          draw.texture(ctx, textures.block, platform.pos, platform_size, 0.0)
        },
      )
      |> draw.texture(
        textures.checkpoint,
        lvl1_checkpoint,
        checkpoint_size,
        0.0,
      )
    }
    Level2(player, platforms, textures) -> fn(ctx) {
      draw.texture(ctx, textures.player, player.pos, player_size, 0.0)
      |> list.fold(
        platforms,
        _,
        fn(ctx, platform) {
          draw.texture(ctx, textures.block, platform.pos, platform_size, 0.0)
        },
      )
      |> draw.texture(
        textures.checkpoint,
        lvl2_checkpoint,
        checkpoint_size,
        0.0,
      )
    }
  }
  Nil
}
