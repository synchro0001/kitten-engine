## 01 Pong

This is a very simple recreation of the game "pong".

Just like last time, we begin with our `Model` type. We don't have to include everything in it from the start; only the data we need to start writing our `update` and `view` functions. 

The only dynamic data that we need to store is the position and velocity of the ball and the player's `y` position. The player's `x` position is fixed, so we define it as a constant. As for the opponent's position, the `y` will always be the same as the ball (so the game is impossible to beat), and the `x` the same as the player but with the opposite sign, so we do not need to store any information in the model.

```gleam
import kitten/vec2.{type Vec2, Vec2}

type Model {
  Model(
    ball_pos: Vec2,
    ball_vel: Vec2,
    player_y: Float,
  )
}

const player_x = -250.0

const player_vel = 5.0

const pad_width = 10.0

const pad_height = 50.0

const ball_radius = 8.0
```

We will intiate the ball in the centre of the screen moving towards the opponent, and the player at `y = 0.0`: 

```gleam
fn init() {
  Model(
    ball_pos: Vec2(0.0, 0.0),
    ball_vel: Vec2(2.0, 0.8),
    player_y: 0.0,
  )
}
```

Let's also add a `view` function like this, using pre-defined colours from the `color` module: 

```gleam
import kitten/draw
import kitten/color

fn view() {
  draw.context()
  |> draw.background(color.slate_900)
  // the player's pad
  |> draw.rect(
    Vec2(player_x, model.player_y),
    Vec2(pad_width, pad_height),
    color.grey_100,
    )
  // the opponent's pad
  |> draw.rect(
    Vec2(0.0 -. player_x, model.ball_pos.y),
    Vec2(pad_width, pad_height),
    color.grey_100,
    )
  // the ball
  |> draw.circle(model.ball_pos, ball_radius, color.grey_100)
}
```

And as before, we can add a placeholder `update` function and start the engine to check that everything works:

```gleam
import kitten/canvas

pub fn main() {
  canvas.start_window(init, update, view, "canvas", 1920.0, 1080.0, [], [])
}

fn update(model: Model) {
  model
} 
```

Let's start writing the `update` function by adding the ability for the player to control their pad. The code is very similar to what we saw in the previous example and even slightly simpler because we only need to update a `Float`, not a `Vec2` (remember, the player's `x`-coordinate is constant). For some reason, I've decided that "A" and "S" would be good keys to use for "up" and "down". Note that we've also brought in the `mouse` module to support touch controls: pressing the left side of the screen brings the pad up, and the right side -- down.

```gleam
import gleam/function.{identity as id}
import gleam/float

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
  Model(..model, player_y:)
}
```

Next, we increment the ball's position using the `simulate.move` function. 

```gleam
// inside the update() function
let Vec2(x, y) as ball_pos = simulate.move(model.ball_pos, model.ball_vel)
```

And now we can check if the player has hit the ball in the frame (this will also be useful for scoring later):

```gleam
// inside the update() function
let player_hit_ball =
  // ball overlaps with the player horizontally
  x <. player_x +. pad_width /. 2.0 +. ball_radius
  // the ball's centre is on the same height as the pad
  && y <. model.player_y +. pad_height /. 2.0
  && y >. model.player_y -. pad_height /. 2.0
  // the ball is moving towards the player's pad
  && model.ball_vel.x <. 0.0
```

With this, we can add an expression to update the ball's velocity. First of all, we want it to accelerate slighly on every frame, but not to go too fast (hence the clamping). Then, we check if it was hit by either the player or the opponent and invert the `x` component if so; and if the ball goes too high or too low, we invert the `y` component.

```gleam
// inside the update function
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
```

And now our `update` function should return this:

```gleam 
Model(
  ball_pos:,
  ball_vel:,
  player_y:,
)
```

Let's add two horizontal rectangles to the `view` function to represent the floor and ceiling and see what the game looks like.

```gleam
// inside the view() function
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
```

At this point, the game is playable, but not very exciting. If the player misses the ball, the simulation will just continue (and in fact, the player can fling the ball back from behind the pad due to the way we coded the collision check); there is also no score. 

To solve these issues, we once again begin with our model and add two new fields to the `Model` type.

```gleam
type Model {
  Model(
    ball_pos: Vec2,
    ball_vel: Vec2,
    player_y: Float,
    has_lost: Bool,
    score: Int,
  )
}
```

By starting with the model, we can use the Gleam compiler to minimise errors in our refactoring. 

First of all, let's update our `init` function with some sensible initial values:

```gleam
fn init() {
  Model(
    ball_pos: Vec2(0.0, 0.0),
    ball_vel: Vec2(2.0, 0.8),
    player_y: 0.0,
    has_lost: False,
    score: 0,
  )
}
```

It is easy to keep track of the score; we just need to add the following to the `update` function:

```gleam
// inside the update() function
let score = case player_hit_ball && !model.has_lost {
  True -> model.score + 1
  False -> model.score
}
```

Finally, let's change what the `update` function returns. We want to be able to reset a lost game by pressing "Space" or touching anywhere on the screen, so if the game was lost and either of those actions happened, we can simply return the initial model.

```gleam
// inside the update() function
case
  model.has_lost && { key.is_down(key.Space) || mouse.was_pressed(mouse.LMB) }
{
  True -> init()
  False -> todo
}
```

But how do we know if a game was lost? Well, if the game was already lost on a previous frame, we do not need to do anything. Otherwise, the game is lost if and only if the position of the ball is too far left; in this case, I have found the value of `-265.0` to work well. 

```gleam
// inside the update() function
False ->
  Model(
    ball_pos:,
    ball_vel:,
    player_y:,
    has_lost: x <. -265.0 || model.has_lost,
    score:,
  )
```

This is not a perfect solution (for example, it does not actually stop the simulation after the game was lost), but it works well enough for our purposes.

Finally, let's update the `view` function. If the game has not yet been lost, we will need to draw the pads and the ball. If it has, we need to draw some text to inform the player of this fact. In either case, we will draw the background, the name of the game, the player's score and the floor and ceiling for visual separation.

```gleam
import gleam/int

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
```

That's it! Our first actually playable game is done. The highest score I've been able to get is 24, but I'm sure you can beat it with some practice.

*Bonus*: In its current state, the game is impossible to beat. Try to think of a creative way to nerf the opponent and make the game winnable. If, as part of your plan, you want to increase the speed of the ball, take care that your collisions are still detected correctly. 
