# Kitten

[![Package Version](https://img.shields.io/hexpm/v/net)](https://hex.pm/packages/kitten)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/kitten/)

```sh
gleam add kitten
```

Kitten is a simple in-browser game engine, based on the HTML canvas element. It uses the model-view-update architecture and provides a handful of utility functions to make game development easier and safer.

Further documentation can be found at <https://hexdocs.pm/kitten>.

Look at the examples directory on github to learn more.

## Example

```gleam
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
```

## Quick start

Since kitten runs in the browser, you will need to compile your game code to javascript and attach it to an HTML file. To start, add `target = "javascript"` to your `gleam.toml` file. Next, create an `index.html` file in your project folder and copy this markdown into it, replacing `demo_proj` and `demo` with the names of your project and main file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <canvas id="canvas"></canvas>
    <script type="module">
        import { main } from "./build/dev/javascript/demo_proj/demo.mjs";
        main();
    </script>
</body>
</html>
```

Now, just write some gleam code in your main file (I suggest you copy the example from above). Run `gleam build` in the terminal, open the HTML file, and that's it. You should be able to see a red box on your screen that you can move with the WASD keys.

To learn more about how the engine works, I suggest you look at the `examples` directory in the Github repo. Make sure to read its README before looking at the example games.

## Further development

The engine is far from complete at the moment. Particularly on the javascript side, the code is simply a mess of everything that I could get to work from other projects and ChatGPT. I am also not too happy with some of the modules, so expect changes in the near future. 

Here are some things that I would like to add to the engine, but so far haven't figured out how to implement them or how they would fit in: 
- [ ] a more consistent and general `simulate` module with higher-order abstractions and optimisations
- [ ] shaders (with WebGL)
- [ ] effects, like in [Lustre](https://github.com/lustre-labs/lustre), for tasks like communicating with a server; possible even a Lustre integration
- [ ] better documentation and a partial rewrite of the javascript code
- [ ] tests 
- [ ] 3D and 3D-ish (eg isometric) support

If you have ideas on how to make any of this happen, please open a PR or a discussion on Github. All contributions are welcome.

## Credits

The kitten engine is heavily inspired by the [LittleJS engine](https://github.com/KilledByAPixel/LittleJS) by Frank Force (KilledByAPixel) and borrows many of its features and some of its code from LittleJS.

As part of the audio system, kitten includes [ZzFX](https://github.com/KilledByAPixel/ZzFX) and [ZzFXM](https://github.com/keithclark/ZzFXM) by Frank Force and Keith Clark. Both sound systems have very useful websites for creating audio: [ZzFX](https://killedbyapixel.github.io/ZzFX/), [ZzFXM](https://keithclark.github.io/ZzFXM/). 

The pre-defined colours in the `color` module are taken directly from [Pico CSS](https://picocss.com/docs/colors). Use their website to browse the colour collection online.

All of the above are licensed under the MIT license.