## 02 Breakout

This is a recreation of the breakout game. In this explanation, I will focus less on the fine implementation details than before and pay more attention to the architecture of the game. If you struggle to understand something in the source code, feel free to look at the previous examples or at the module documentation on Hex. 

There are many versions of Breakout out there, so I will briefly describe what we're trying to do here (you can also download the index.html and breakout.js files to see it for yourself). The game starts with some blocks, each of which has a certain durability. The player has a handful of balls which they can shoot in a straight line into the blocks. The balls bounce off blocks, walls and the ceiling, but once they hit the floor, they stay there until the next shot. Every time a ball hits a block, it loses some durability and eventually breaks. Once all blocks are broken, the game is won.

The model that we will use for this game is a *state machine* (strictly speaking, I believe that all of our games so far have been infinite state machines, but that's beyond the point). Throughout the game, the player will transition between these states:
- *Idle*: able to shoot the balls, but has not initiated the shot yet.
- *Shooting*: the balls must be dispatched with a certain cooldown.
- *Collecting*: the balls no longer need to be dispatched, but the player cannot make a shot yet as some balls are still in the air.

```gleam
type PlayerState {
  Idle
  Shooting
  Collecting
}
```

Beside the player state, there a few more things that we need to store in the model. These include information about the balls and blocks (which we store in custom types for convenience), and some information that needs to be preserved between frames for the `Shooting` state: the direction in which to shoot the balls and the cooldown to make sure we are not shooting one on every frame (yes, from the viewpoint of purity, these should probably be stored somewhere together with that state, but this works well enough). Note also that each ball can be one of three states: `OnGround` (before being shot), `InAir` and `HasLanded`; these will help us transition between player states later on.

```gleam
type Model {
  Model(
    player: PlayerState,
    direction: Vec2,
    balls: List(Ball),
    blocks: List(Block),
    cooldown: Int,
  )
}

type PlayerState {
  Idle
  Shooting
  Collecting
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
```

The `init` function is very simple: it just creates the balls, randomly generates some blocks, and places them all on the screen. If you are looking at the source code, don't worry, we'll get to the `palette` and `sound` parts shortly.

Now that we have the states of our state machine set up, let's think about the transitions between them. If the player is `Idle`, we only need to wait for them to take a shot. If they do, we will update the shooting `direction` in the model based on the current mouse position, and set the new state to `Shooting`; otherwise, we don't need to do anything. 

```gleam
fn update(model: Model) {
  case model.player {
    Idle ->
      case
        mouse.was_released(mouse.LMB)
        // check that the mouse is within the playing field
        && simulate.is_within(mouse.pos(), Vec2(0.0, 0.0), Vec2(620.0, 620.0))
      {
        True -> {
          // since the balls are all in one spot, 
          // we might as well use the position of the first one 
          let assert Ok(first_ball) = model.balls |> list.first
          let direction =
            vec2.subtract(mouse.pos(), first_ball.pos)
            |> vec2.set_length(5.0)
          Model(..model, player: Shooting, direction:)
        }
        _ -> model
      }
      // ...
  }
}
```

Next up, what if the player is already `Shooting`? If all the balls have already have been released, i.e. the last one is in the air, we transition to `Collecting`; otherwise, we continue shooting and simulate the motion of the balls.

```gleam
    Shooting -> {
      let assert Ok(last_ball) = list.last(model.balls)
      case last_ball.state == InAir {
        True -> Model(..model, player: Collecting)
        // dispatch new balls, simulate ball motion
        False -> todo
      }
    }
```

And finally, if the player state is `Collecting`, we need to check if all the balls have landed already. If so, we stop collecting and transition to `Idle` (and also put all the balls in one spot so that it is possible to aim unambiguously); if not, we continue collecting the balls and simulate their motion.

```gleam
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
        // simulate ball motion
        False -> todo
      }
```

Since the simulation of ball motion is common across two parts of our code that is missing, it is a good place to start. Although it is definitely overkill in this circumstance, for demonstration purposes, we will use the `simulate.collision` function. What we need is a function (called simply `simulate` in the code) that will take in a list of balls and blocks and return their new velocities by passing them into the helper function. The tricky part is that the transformation needs to be *stateful*: for every simulated collision, we want to take the result of that simulation and pass it on to the other collisions.

To achieve this, we will use two nested `list.map_fold` functions. For each ball, we will `map_fold` over the list of all blocks, passing information about the position of the ball after each collision on to the next. Now, the trick is that we then do same for the next ball and the next one and so on, but because we are `map_fold`ing over the list of balls, we can take the new list of blocks and just pass it into the transformation for the next block. This sounds complicated, but in reality, once you understand how `map_fold` helps you turn a stateless mapping into a stateful one, the Gleam compiler will make sure that you get the details of the implementation right.

The code for the interaction between a single ball and a single block is actually very simple. First, we check if there is any overlap; if not, we make an early return with no adjustments. Then we decrement the block's durability and again make an early return if the block is broken. Finally, we use the `simulate.collision` to update the ball's velocity. Note that since this helper function does not change the position of the balls, we will need to do that with a `simulate.move` function in our `update` function.

```gleam
fn simulate(
  balls: List(Ball),
  blocks: List(Block),
) -> #(List(Ball), List(Block)) {
  balls
  |> list.map_fold(blocks, fn(blocks, ball) {
    list.map_fold(blocks, ball, fn(ball, block) {
      use <- guard(!block.is_showing, return: #(ball, block))
      let block_durability = case
        simulate.is_overlapping(ball.pos, ball_size, block.pos, block_size)
      {
        True -> block.durability - 1
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
  |> pair.swap
}
```

Finally, since the role of this `simulate` function is to update the velocity and state of the balls, we can add code to make them bounce off the walls and ceiling and change their state to `HasLanded` once they hit the floor.

```gleam
fn simulate(
  balls: List(Ball),
  blocks: List(Block),
) -> #(List(Ball), List(Block)) {
  let #(blocks, balls) = // ...
  #(
    balls
      |> list.map(fn(ball) {
        let ball = case
          ball.pos.x >=. 300.0
          && ball.vel.x >. 0.0
          || ball.pos.x <=. -300.0
          && ball.vel.x <. 0.0
        {
          True ->
            Ball(
              pos: ball.pos |> vec2.set_y(-300.0),
              vel: Vec2(0.0, 0.0),
              state: HasLanded,
            )
          False -> ball
        }
        let ball = case float.absolute_value(ball.pos.x) >=. 300.0 {
          True -> Ball(..ball, vel: ball.vel |> vec2.multiply(Vec2(-1.0, 1.0)))
          False -> ball
        }
        case ball.pos.y >=. 300.0 {
          True -> Ball(..ball, vel: ball.vel |> vec2.multiply(Vec2(1.0, -1.0)))
          False -> ball
        }
      }),
    blocks,
  )
}
```

With this, we can quickly finish the "simulate" branch of the `Collecting` case of the `update` function (see source code -- remember that `simulate` does not change the positions of the balls, only their velocities) and move on to the next challenge: how do we dispatch balls during the `Shooting` phase?

In reality, this is quite simple. We already have a `countdown` field in our model, so all we need to do is to check that it has reached a high enough value and then loop over all the balls, find the first one that is not in the air yet, and set its velocity to the `direction` (which we also store in our model). The other balls do not need to be updated at this stage. The requirement to find the first ball that is on the ground makes this another stateful transformation, so we again use `list.map_fold` -- see the code for details.

```gleam
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
```

That completes our `update` function, and we can move on to the `view` function. We can set the background and draw the balls as usual, but what we're interested in is the colour of the blocks. Here, I want to showcase how you would create custom colours for your game using the `color` module. Let's say I want the blocks' colours to reflect how much durability left, and for some reason (I am not an artist), I want them to only differ in hue, but not saturation or lightness. The naive way to do this would be to define the colours on every call to the `view` function like this, and them use those to draw the blocks:

```gleam
fn view(model: Model) {
  let assert Ok(dur10) = color.from_hsl(0, 90, 50)
  let assert Ok(dur20) = color.from_hsl(40, 90, 50)
  let assert Ok(dur30) = color.from_hsl(80, 90, 50)
  let assert Ok(dur40) = color.from_hsl(120, 90, 50)
  let assert Ok(dur50) = color.from_hsl(160, 90, 50)
  // ...
}
```

This works, but doesn't allow us to effectively leverage the fallibility of these color-creating functions. They are fallible for a reason; they will only work if the parameters you called them with represent a valid colour. However, if you call these functions only when you need the colour and it fails, this won't be too helpful: you would probably be able to tell that something went wrong just by looking at the screen. To prevent this, I highly recommend that you define your custom colours in the `init` function and store them in your model. This way, if the game starts without errors, you'll know that the colours are correct. 

So, in our code we will define a custom `Palette` type to store our custom colours, and simply add it to our model. Again, see the source code for full implementation details.

```gleam
type Model {
  Model(
    player: PlayerState,
    direction: Vec2,
    balls: List(Ball),
    blocks: List(Block),
    cooldown: Int,
    palette: Palette,
  )
}

type Palette {
  Palette(dur10: Color, dur20: Color, dur30: Color, dur40: Color, dur50: Color)
}
```

At this point, the game is playable, but we can take it a step further. Let's add a "You win!" screen that will display once the player has destroyed every block. We could add a boolean `has_won` to our model like we did in the pong example, but our state machine provides a better way: let's simply expand our `PlayerState` type with a new variant, `HasWon`. Now, we will enter this state from the `Idle` state if every block has been broken, and if the player is already in the `HasWon` state, we do not need to update the model. 

```gleam
// inside the update() function
Idle ->
  case
    list.all(model.blocks, fn(block) { !block.is_showing }),
    mouse.was_released(mouse.LMB)
    && simulate.is_within(mouse.pos(), Vec2(0.0, 0.0), Vec2(620.0, 620.0))
  {
    True, _ -> Model(..model, player: HasWon)
    _, True -> // ...
    _, _ -> // ...
  } 
  // ...
HasWon -> model
```

As a final touch, let's add some sound effects. We will use [ZzFX](https://killedbyapixel.github.io/ZzFX/) to generate a simple thud to play every time a ball hits a block. Then, we wil store it in a `hit.js` file and pass that file into the `canvas.start_window` function:

```gleam
pub fn main() {
  canvas.start_window(init, update, view, "canvas", 1920.0, 1080.0, [], ["hit.js"])
}
```

Much like we did with the colours, we will create the hit `Sound` inside the `init` function to ensure our own safety, and then store it in the model.

```gleam
fn init() {
  //...

  let assert Ok(hit_sound) = sound.new(0)
  Model(
    // ... 
  hit_sound)
}
```
Finally, since the individual collisions 'happen' within the `simulate` function, we will pass the sound from the model as one of the arguments and add `sound.play` as a side effect whenever the durability of a block decreases or a ball hits the wall or the ceiling.

And that completes our game. I've found the state machine model very useful, and I hope you like it too. 

*Bonus*: It is currently impossible to lose in this game. The player can keep shooting balls forever until they eventually destroy every blook. Implement some way for the player to lose; for example, after each shot, the blocks could move down a bit, and once a block touches the floor, the game is lost. While you're at it, you might want to add a way to reset the game once you have lost or won; this should be a simple extra transition in the state machine.