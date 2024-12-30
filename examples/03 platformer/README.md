## 03 Platformer

This is a very simple platformer game. Just as in the previous example, I will not be focusing on the details of the code, but rather on the general principles behind it.

We begin, as always, with the model. Previously, our `Model` type only had one variant, but this does not have to be the case by any means. Since I want the game to have two levels and a menu, which need to store different types of state, I will declare three variants of the model: `Menu`, `Level1` and `Level2`. Again, these will work as the states of our state machine, with very simple transitions between them: 

```gleam
fn update(model: Model) {
  case model {
    Menu(textures) ->
      case
        mouse.is_down(mouse.LMB),
        simulate.is_within(mouse.pos(), Vec2(-200.0, 0.0), Vec2(300.0, 300.0)),
        simulate.is_within(mouse.pos(), Vec2(200.0, 0.0), Vec2(300.0, 300.0))
      {
        False, _, _ | True, False, False -> model
        // player clicked on "level 1"
        True, True, _ -> init_lvl1(textures)
        // player clicked on "level 2"
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
        // exit to menu
        _, True -> init_menu(textures)
        // stay on this level
        False, False -> update_lvl1(player, platforms, textures)
        // level complete -- transition to level 2
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
        // exit to menu
        _, True -> init_menu(textures)
        // stay on this level
        False, False ->
          update_lvl2(player, platforms, textures)
        // level complete -- transition to menu
        True, False -> init_menu(textures)
      }
  }
}
```

Notice how having multiple variants of the model forces us to deconstruct it every time, which in turn makes it trivial to separate behaviours into little functions (like `update_lvl1`) which take the model's fields as arguments.

Next up, you have probably noticed the `textures` field in the above code. Kitten supports drawing custom textures to the screen, so you're not stuck with just rectangles and circles. I've put together some very simple pixel art textures in the `textures.png` file and passed the name of that file as an image source when starting the engine:

```gleam
  canvas.start_window(init, update, view, "canvas", 1920.0, 1080.0, ["textures.png"], [])
```

Next, as we've previously done with colours and sounds, we will create the textures in our `init` function and store them in a custom `Textures` record: 

```gleam
fn init() {
  let assert Ok(block_texture) = draw.create_texture(0, 0, 0, 16, 8)
  let assert Ok(player_texture) = draw.create_texture(0, 16, 0, 8, 8)
  let assert Ok(checkpoint_texture) = draw.create_texture(0, 24, 0, 8, 8)
  let textures = Textures(block_texture, player_texture, checkpoint_texture)
}
```

We will then pass these textures into our initial `Menu` model and pass them around whenever the model changes. 

The final interesting thing about this game is its physics. Kitten's physics system (located in the `simulate` module) is still a bit fiddly and needs some work, but it is usable.

Consider just level 1 for a moment. On every frame, we need to check if the player is standing on a platform, and if so, we will allow them to press "W" to jump. "A" and "D" can be pressed at any time to change the horizontal position. We then simulate the collisions between the player and the platforms and finally move the player through their new velocity.

```gleam   
fn update_lvl1(player: Player, platforms: List(Platform), textures) {
  // reset the level if the player falls down
  use <- guard(player.pos.y <. -500.0, return: init_lvl1(textures))
  // check if a slightly smaller and down-shifted rectangle than the player overlaps with any platforms
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
  // update the velocity with the x component, gravity and a jump
  let player_vel =
    Vec2(player_vel_x, player.vel.y)
    |> simulate.apply_gravity(10.0, 5.0)
    |> case key.was_pressed(key.W) && player_is_grounded {
      True -> simulate.apply_forces(_, 1.0, [Vec2(0.0, 15.0)])
      False -> vec2.id
    }
  let player = Player(player.pos, player_vel)
  // simulate collisions
  let #(player, platforms) =
    platforms
    |> list.map_fold(player, fn(player, platform) {
      let #(#(player_pos, player_vel), _) =
        simulate.collision(
          #(player.pos, player_size, player.vel, 10.0),
          #(platform.pos, platform_size, Vec2(0.0, 0.0), 0.0),
          e: 0.0,
          f: 0.1,
        )
      #(Player(player_pos, player_vel), platform)
    })
  // move the player
  let player = simulate.move(player.pos, player.vel) |> Player(player.vel)
  Level1(player:, platforms:, textures:)
}
```

Let's now see how we can very simply extend this code to add a second level. The only new feature on that level will be moving platforms, so we extend our `Platform` type into two variants: `StaticPlatform` and `MovingPlatform`. Next, we extract the functionality for updating the player and simulating the collisions between the player and the platforms into helper functions for reusability. Finally, we will need an `update_platforms` that does nothing with static platforms but moves moving platforms between two points (the dark magic with dot products is simply for determinig the correct direction). 

```gleam
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
```

With this, we can rewrite our `update` functions in a very concise and consistent way.

```gleam
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
```

And that's the game done. The `view` function simply renders the textures in the specified locations, like we previously did with rectangles.

This also concludes our tour of the kitten engine. I hope you liked what you saw. If you have any suggestions on what I could improve, or want to contribute in any other way, please do get in touch.

*Bonus*: add more levels and features to the game. The best submissions will be pooled together into a "community edition" of the game and made public.