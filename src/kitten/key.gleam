//// This module contains a few simple functions to work with keyboard input.
//// These are intended for use inside your `update` function.
//// The custom `Key` types ensures that you can only check for real keys and prevents misspellings.
//// Use `key.ANY` to check if any key was pressed, released or was down during a frame.
//// 
//// ## Example: 
//// 
//// ```gleam
//// let new_pos = case key.is_down(key.A) {
////   True -> pos |> vec2.add(Vec2(1.0, 0.0))
////   False -> pos
//// }
//// ```

pub type Key {
  ANY
  A
  B
  C
  D
  E
  F
  G
  H
  I
  J
  K
  L
  M
  N
  O
  P
  Q
  R
  S
  T
  U
  V
  W
  X
  Y
  Z
  Space
  ArrowLeft
  ArrowUp
  ArrowRight
  ArrowDown
  Backspace
  Tab
  Enter
  ShiftLeft
  ShiftRight
  ControlLeft
  ControlRight
  AltLeft
  AltRight
  Pause
  CapsLock
  Escape
  PageUp
  PageDown
  End
  Home
  PrintScreen
  Insert
  Delete
  Digit0
  Digit1
  Digit2
  Digit3
  Digit4
  Digit5
  Digit6
  Digit7
  Digit8
  Digit9
  MetaLeft
  MetaRight
  ContextMenu
  Numpad0
  Numpad1
  Numpad2
  Numpad3
  Numpad4
  Numpad5
  Numpad6
  Numpad7
  Numpad8
  Numpad9
  NumpadMultiply
  NumpadAdd
  NumpadSubtract
  NumpadDecimal
  NumpadDivide
  F1
  F2
  F3
  F4
  F5
  F6
  F7
  F8
  F9
  F10
  F11
  F12
  NumLock
  ScrollLock
  AudioVolumeMute
  AudioVolumeDown
  AudioVolumeUp
  LaunchMediaPlayer
  LaunchApplication1
  LaunchApplication2
  Semicolon
  Equal
  Comma
  Minus
  Period
  Slash
  Backquote
  BracketLeft
  Backslash
  BracketRight
  Quote
}

fn to_code(k: Key) -> String {
  case k {
    ANY -> ""
    A -> "KeyA"
    B -> "KeyB"
    C -> "KeyC"
    D -> "KeyD"
    E -> "KeyE"
    F -> "KeyF"
    G -> "KeyG"
    H -> "KeyH"
    I -> "KeyI"
    J -> "KeyJ"
    K -> "KeyK"
    L -> "KeyL"
    M -> "KeyM"
    N -> "KeyN"
    O -> "KeyO"
    P -> "KeyP"
    Q -> "KeyQ"
    R -> "KeyR"
    S -> "KeyS"
    T -> "KeyT"
    U -> "KeyU"
    V -> "KeyV"
    W -> "KeyW"
    X -> "KeyX"
    Y -> "KeyY"
    Z -> "KeyZ"
    Space -> "Space"
    ArrowUp -> "ArrowUp"
    ArrowDown -> "ArrowDown"
    ArrowLeft -> "ArrowLeft"
    ArrowRight -> "ArrowRight"
    Backspace -> "Backspace"
    Tab -> "Tab"
    Enter -> "Enter"
    ShiftLeft -> "ShiftLeft"
    ShiftRight -> "ShiftRight"
    ControlLeft -> "ControlLeft"
    ControlRight -> "ControlRight"
    AltLeft -> "AltLeft"
    AltRight -> "AltRight"
    Pause -> "Pause"
    CapsLock -> "CapsLock"
    Escape -> "Escape"
    PageUp -> "PageUp"
    PageDown -> "PageDown"
    End -> "End"
    Home -> "Home"
    PrintScreen -> "PrintScreen"
    Insert -> "Insert"
    Delete -> "Delete"
    Digit0 -> "Digit0"
    Digit1 -> "Digit1"
    Digit2 -> "Digit2"
    Digit3 -> "Digit3"
    Digit4 -> "Digit4"
    Digit5 -> "Digit5"
    Digit6 -> "Digit6"
    Digit7 -> "Digit7"
    Digit8 -> "Digit8"
    Digit9 -> "Digit9"
    MetaLeft -> "MetaLeft"
    MetaRight -> "MetaRight"
    ContextMenu -> "ContextMenu"
    Numpad0 -> "Numpad0"
    Numpad1 -> "Numpad1"
    Numpad2 -> "Numpad2"
    Numpad3 -> "Numpad3"
    Numpad4 -> "Numpad4"
    Numpad5 -> "Numpad5"
    Numpad6 -> "Numpad6"
    Numpad7 -> "Numpad7"
    Numpad8 -> "Numpad8"
    Numpad9 -> "Numpad9"
    NumpadMultiply -> "NumpadMultiply"
    NumpadAdd -> "NumpadAdd"
    NumpadSubtract -> "NumpadSubtract"
    NumpadDecimal -> "NumpadDecimal"
    NumpadDivide -> "NumpadDivide"
    F1 -> "F1"
    F2 -> "F2"
    F3 -> "F3"
    F4 -> "F4"
    F5 -> "F5"
    F6 -> "F6"
    F7 -> "F7"
    F8 -> "F8"
    F9 -> "F9"
    F10 -> "F10"
    F11 -> "F11"
    F12 -> "F12"
    NumLock -> "NumLock"
    ScrollLock -> "ScrollLock"
    AudioVolumeMute -> "AudioVolumeMute"
    AudioVolumeDown -> "AudioVolumeDown"
    AudioVolumeUp -> "AudioVolumeUp"
    LaunchMediaPlayer -> "LaunchMediaPlayer"
    LaunchApplication1 -> "LaunchApplication1"
    LaunchApplication2 -> "LaunchApplication2"
    Semicolon -> "Semicolon"
    Equal -> "Equal"
    Comma -> "Comma"
    Minus -> "Minus"
    Period -> "Period"
    Slash -> "Slash"
    Backquote -> "Backquote"
    BracketLeft -> "BracketLeft"
    Backslash -> "Backslash"
    BracketRight -> "BracketRight"
    Quote -> "Quote"
  }
}

/// Returns `True` if the key was pressed in the time since the last frame,
/// but has not yet been released, and `False` otherwise.
pub fn is_down(key: Key) -> Bool {
  case key {
    ANY -> do_any_key_is_down()
    _ -> do_key_is_down(to_code(key))
  }
}

@external(javascript, "../kitten_ffi.mjs", "keyIsDown")
fn do_key_is_down(key: String) -> Bool

@external(javascript, "../kitten_ffi.mjs", "anyKeyIsDown")
fn do_any_key_is_down() -> Bool

/// Returns `True` if the key was pressed in the time since the last frame,
/// and `False` otherwise.
pub fn was_pressed(key: Key) -> Bool {
  case key {
    ANY -> do_any_key_was_pressed()
    _ -> do_key_was_pressed(to_code(key))
  }
}

@external(javascript, "../kitten_ffi.mjs", "keyWasPressed")
fn do_key_was_pressed(key: String) -> Bool

@external(javascript, "../kitten_ffi.mjs", "anyKeyWasPressed")
fn do_any_key_was_pressed() -> Bool

/// Returns `True` if the key was released in the time since the last frame,
/// and `False` otherwise.
pub fn was_released(key: Key) -> Bool {
  case key {
    ANY -> do_any_key_was_released()
    _ -> do_key_was_released(to_code(key))
  }
}

@external(javascript, "../kitten_ffi.mjs", "keyWasReleased")
fn do_key_was_released(key: String) -> Bool

@external(javascript, "../kitten_ffi.mjs", "anyKeyWasReleased")
fn do_any_key_was_released() -> Bool
