import { Ok as $Ok, Error as $Error } from "../prelude.mjs";

////////// engine //////////

let images = [];
let sounds = {};
let lastTime = 0;
let deltaTime;

function startEngine(init, update, view, imageSources, soundSources) {
  // run on every frame
  function gameLoop(timestamp, model) {
    const _deltaTime = timestamp - lastTime;
    // caps fps at 60
    if (_deltaTime > 16.6) {
      deltaTime = _deltaTime;
      view(model);
      const updatedModel = update(model);
      lastTime = timestamp;
      clearInput();
      requestAnimationFrame((t) => gameLoop(t, updatedModel));
    } else {
      requestAnimationFrame((t) => gameLoop(t, model));
    }
  }

  // Setting up canvas
  const canvas = document.getElementById(canvasId);
  canvas.getContext("2d").imageSmoothingEnabled = false; // prevent blurry textures
  canvas.style.display = "block";

  // Initialising input, images, and sounds
  initKeyInput();
  initMouseInput();

  // Loading images
  const imagePromises = imageSources.toArray().map(
    (src, imgId) =>
      new Promise((resolve) => {
        const image = new Image();
        image.onload = () => {
          images[imgId] = image;
          resolve();
        };
        image.onerror = () => {
          console.error(`Failed to load image ${imgId}`);
        };
        image.src = src;
      })
  );

  // Loading sounds
  const soundPromises = soundSources.toArray().map(async (source, index) => {
    if (source.endsWith(".js")) {
      try {
        await renderZzFXMSong(source, index);
      } catch (_error) {
        await renderZzFXSound(source, index);
      }
    } else {
      await renderFileSound(source, index);
    }
  });

  // Starting engine
  Promise.all([Promise.all(imagePromises), Promise.all(soundPromises)])
    .then(() => {
      const initialModel = init();
      requestAnimationFrame((t) => gameLoop(t, initialModel));
    })
    .catch((error) => {
      console.error("Failed to start engine:", error);
    });
}

export function getDeltaTime() {
  return (deltaTime * 60) / 1000;
}

////////// canvas //////////

let canvasId;
let canvasWidth;
let canvasHeight;
let canvasScale;

export function startWindow(
  init,
  update,
  view,
  _canvasId,
  _canvasWidth,
  _canvasHeight,
  imageSources,
  soundSources
) {
  document.body.style.margin = "0";
  document.body.style.padding = "0";
  document.body.style.overflow = "hidden";

  document.documentElement.style.margin = "0";
  document.documentElement.style.padding = "0";
  document.documentElement.style.overflow = "hidden";

  document.getElementById(_canvasId).style.position = "absolute";

  canvasId = _canvasId;
  canvasWidth = _canvasWidth;
  canvasHeight = _canvasHeight;
  resizeCanvas();
  window.addEventListener("resize", () => resizeCanvas());

  startEngine(init, update, view, imageSources, soundSources);
}

function resizeCanvas() {
  const canvas = document.getElementById(canvasId);
  if (canvasWidth / canvasHeight >= window.innerWidth / window.innerHeight) {
    canvas.width = window.innerWidth;
    canvasScale = window.innerWidth / canvasWidth;
    canvas.height = canvasHeight * canvasScale;
    canvas.style.top = `${(window.innerHeight - canvas.height) / 2}px`;
    canvas.style.left = `0px`;
  } else {
    canvas.height = window.innerHeight;
    canvasScale = window.innerHeight / canvasHeight;
    canvas.width = canvasWidth * canvasScale;
    canvas.style.top = `0px`;
    canvas.style.left = `${(window.innerWidth - canvas.width) / 2}px`;
  }
  canvas.getContext("2d").imageSmoothingEnabled = false;
}

export function startEmbedded(
  init,
  update,
  view,
  _canvasId,
  _canvasWidth,
  _canvasHeight,
  imageSources,
  soundSources
) {
  canvasId = _canvasId;
  const canvas = document.getElementById(canvasId);
  if (_canvasWidth / _canvasHeight >= canvas.width / canvas.height) {
    canvasScale = canvas.width / _canvasWidth;
  } else {
    canvasScale = canvas.height / _canvasHeight;
  }
  startEngine(init, update, view, imageSources, soundSources);
}

export function toggleFullscreen(toggle) {
  const canvas = document.getElementById(canvasId);
  if (toggle) {
    if (canvas.requestFullscreen) {
      canvas.requestFullscreen();
    } else if (canvas.webkitRequestFullscreen) {
      canvas.webkitRequestFullscreen(); // Safari support
    } else if (canvas.msRequestFullscreen) {
      canvas.msRequestFullscreen(); // IE11 support
    }
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen(); // Safari support
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen(); // IE11 support
    }
  }
}

////////// key //////////

let keyInput = {};

function initKeyInput() {
  window.addEventListener("keydown", (event) => {
    keyInput[event.code] = 0b011;
  });

  window.addEventListener("keyup", (event) => {
    keyInput[event.code] = 0b100;
  });
}

export function keyIsDown(key) {
  return !!(keyInput[key] & 1);
}

export function keyWasPressed(key) {
  return !!(keyInput[key] & 2);
}

export function keyWasReleased(key) {
  return !!(keyInput[key] & 4);
}

export function anyKeyIsDown() {
  for (const key in keyInput) {
    if (!!(keyInput[key] & 1)) {
      return true;
    }
  }
  return false;
}

export function anyKeyWasPressed() {
  for (const key in keyInput) {
    if (!!(keyInput[key] & 2)) {
      return true;
    }
  }
  return false;
}

export function anyKeyWasReleased() {
  for (const key in keyInput) {
    if (!!(keyInput[key] & 4)) {
      return true;
    }
  }
  return false;
}

////////// mouse //////////

let mouseInput = {};
let mousePosition = { x: 0, y: 0 };

function initMouseInput() {
  window.addEventListener("mousedown", (event) => {
    mouseInput[event.button] = 0b011;
    mousePosition.x = event.clientX;
    mousePosition.y = event.clientY;
  });

  window.addEventListener("touchstart", (event) => {
    mouseInput[0] = 0b011;
    mousePosition.x = event.touches[0].clientX;
    mousePosition.y = event.touches[0].clientY;
  });

  window.addEventListener("mouseup", (event) => {
    mouseInput[event.button] = 0b100;
  });

  window.addEventListener("touchend", (event) => {
    mouseInput[0] = 0b100;
  });

  window.addEventListener("mousemove", (event) => {
    mousePosition.x = event.clientX;
    mousePosition.y = event.clientY;
  });

  window.addEventListener("touchmove", function (event) {
    mousePosition.x = event.touches[0].clientX;
    mousePosition.y = event.touches[0].clientY;
  });
}

export function mouseIsDown(button) {
  return !!(mouseInput[button] & 1);
}

export function mouseWasPressed(button) {
  return !!(mouseInput[button] & 2);
}

export function mouseWasReleased(button) {
  return !!(mouseInput[button] & 4);
}

export function getMousePosition() {
  const canvas = document.getElementById(canvasId);
  const boundingRect = canvas.getBoundingClientRect();
  const cornerX = boundingRect.left;
  const cornerY = boundingRect.top;
  // inverse transform
  const iT = canvas.getContext("2d").getTransform().invertSelf();
  // adjust for the canvas position for non-fullscreen canvases
  const x = mousePosition.x - cornerX;
  const y = mousePosition.y - cornerY;
  return [iT.a * x + iT.c * y + iT.e, iT.b * x + iT.d * y + iT.f];
}

////////// draw //////////

export function getContext() {
  const canvas = document.getElementById(canvasId);
  const ctx = canvas.getContext("2d");
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.setTransform(1, 0, 0, -1, canvas.width / 2, canvas.height / 2);
  ctx.scale(canvasScale, canvasScale);
  return ctx;
}

export function drawRect(ctx, cx, cy, w, h, color) {
  const x = cx - w / 2;
  const y = cy - h / 2;
  ctx.fillStyle = color;
  ctx.fillRect(x, y, w, h);
  return ctx;
}

export function drawPath(ctx, points, width, color) {
  points = points.toArray();
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.beginPath();
  ctx.moveTo(points[0][0], points[0][1]);
  for (let i = 1; i < points.length; i++) {
    ctx.lineTo(points[i][0], points[i][1]);
  }
  ctx.stroke();
  return ctx;
}

export function drawPolygon(ctx, points, color) {
  points = points.toArray();
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(points[0][0], points[0][1]);
  for (let i = 1; i < points.length; i++) {
    ctx.lineTo(points[i][0], points[i][1]);
  }
  ctx.closePath();
  ctx.fill();
  return ctx;
}

export function drawLine(ctx, x1, y1, x2, y2, width, color) {
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.beginPath();
  ctx.moveTo(x1, y1);
  ctx.lineTo(x2, y2);
  ctx.stroke();
  return ctx;
}

export function drawEllipse(
  ctx,
  cx,
  cy,
  r1,
  r2,
  tilt,
  startAngle,
  endAngle,
  filled,
  width,
  color
) {
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = width;
  ctx.beginPath();
  ctx.ellipse(cx, cy, r1, r2, tilt, startAngle, endAngle);
  if (filled) {
    ctx.fill();
  } else {
    ctx.stroke();
  }
  return ctx;
}

export function drawCircle(ctx, cx, cy, r, color) {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, 2 * Math.PI);
  ctx.fill();
  return ctx;
}

export function drawText(ctx, text, cx, cy, size, weight, font, tilt, color) {
  // inverting the y axis, otherwise text appears flipped
  ctx.fillStyle = color;
  ctx.textAlign = "center";
  ctx.font = `${weight} ${size}px ${font}`;
  ctx.save();
  ctx.scale(1, -1);
  ctx.translate(cx, -cy);
  ctx.rotate(tilt);
  ctx.fillText(text, 0, -0);
  ctx.restore();
  return ctx;
}

export function drawTexture(ctx, imgId, sx, sy, sw, sh, dx, dy, dw, dh, tilt) {
  ctx.save();
  // inverting the y-axis, otherwise image appears flipped
  ctx.scale(1, -1);
  ctx.translate(dx, -dy);
  ctx.rotate(tilt);
  ctx.drawImage(images[imgId], sx, sy, sw, sh, -dw / 2, -dh / 2, dw, dh);
  ctx.restore();
  return ctx;
}

export function setCameraPos(ctx, new_pos_x, new_pos_y) {
  ctx.translate(-new_pos_x, -new_pos_y);
  return ctx;
}

export function setCameraScale(ctx, new_scale) {
  ctx.scale(new_scale, new_scale);
  return ctx;
}

export function setCameraAngle(ctx, new_angle) {
  ctx.rotate(new_angle);
  return ctx;
}

export function setBackground(ctx, color) {
  ctx.canvas.style.backgroundColor = color;
  // if in fullscreen mode
  if (canvasWidth) {
    document.body.style.backgroundColor = color;
  }
  return ctx;
}

export function checkImgId(id) {
  if (id >= 0 && images.length - 1 >= id) {
    return new $Ok([images[id].width, images[id].height]);
  } else {
    return new $Error(null);
  }
}

////////// input (general) //////////

function clearInput() {
  for (const key in keyInput) {
    keyInput[key] &= 0b001;
  }
  for (const key in mouseInput) {
    mouseInput[key] &= 0b001;
  }
}

////////// simulate //////////

export function screenToWorld(x, y) {
  // inverse transform
  const iT = document
    .getElementById(canvasId)
    .getContext("2d")
    .getTransform()
    .invertSelf();
  x = x * canvasScale;
  y = y * canvasScale;
  return [iT.a * x + iT.c * y + iT.e, iT.b * x + iT.d * y + iT.f];
}

export function worldToScreen(x, y) {
  // direct transform
  const dT = document.getElementById(canvasId).getContext("2d").getTransform();
  return [
    (dT.a * x + dT.c * y + dT.e) / canvasScale,
    (dT.b * x + dT.d * y + dT.f) / canvasScale,
  ];
}

////////// math //////////

export function cos(x) {
  return Math.cos(x);
}

export function sin(x) {
  return Math.sin(x);
}

export function atan2(y, x) {
  return Math.atan2(y, x);
}

////////// ZzFX & ZzFXM //////////

// zzfx() - the universal entry point -- returns a AudioBufferSourceNode
const zzfx = (...t) => zzfxP(zzfxG(...t));

// zzfxP() - the sound player -- returns a AudioBufferSourceNode
const zzfxP = (...t) => {
  let e = zzfxX.createBufferSource(),
    f = zzfxX.createBuffer(t.length, t[0].length, zzfxR);
  t.map((d, i) => f.getChannelData(i).set(d)),
    (e.buffer = f),
    e.connect(zzfxX.destination),
    e.start();
  return e;
};

// zzfxG() - the sound generator -- returns an array of sample data
const zzfxG = (
  q = 1,
  k = 0.05,
  c = 220,
  e = 0,
  t = 0,
  u = 0.1,
  r = 0,
  F = 1,
  v = 0,
  z = 0,
  w = 0,
  A = 0,
  l = 0,
  B = 0,
  x = 0,
  G = 0,
  d = 0,
  y = 1,
  m = 0,
  C = 0
) => {
  let b = 2 * Math.PI,
    H = (v *= (500 * b) / zzfxR ** 2),
    I = ((0 < x ? 1 : -1) * b) / 4,
    D = (c *= ((1 + 2 * k * Math.random() - k) * b) / zzfxR),
    Z = [],
    g = 0,
    E = 0,
    a = 0,
    n = 1,
    J = 0,
    K = 0,
    f = 0,
    p,
    h;
  e = 99 + zzfxR * e;
  m *= zzfxR;
  t *= zzfxR;
  u *= zzfxR;
  d *= zzfxR;
  z *= (500 * b) / zzfxR ** 3;
  x *= b / zzfxR;
  w *= b / zzfxR;
  A *= zzfxR;
  l = (zzfxR * l) | 0;
  for (h = (e + m + t + u + d) | 0; a < h; Z[a++] = f)
    ++K % ((100 * G) | 0) ||
      ((f = r
        ? 1 < r
          ? 2 < r
            ? 3 < r
              ? Math.sin((g % b) ** 3)
              : Math.max(Math.min(Math.tan(g), 1), -1)
            : 1 - (((((2 * g) / b) % 2) + 2) % 2)
          : 1 - 4 * Math.abs(Math.round(g / b) - g / b)
        : Math.sin(g)),
      (f =
        (l ? 1 - C + C * Math.sin((2 * Math.PI * a) / l) : 1) *
        (0 < f ? 1 : -1) *
        Math.abs(f) ** F *
        q *
        zzfxV *
        (a < e
          ? a / e
          : a < e + m
          ? 1 - ((a - e) / m) * (1 - y)
          : a < e + m + t
          ? y
          : a < h - d
          ? ((h - a - d) / u) * y
          : 0)),
      (f = d
        ? f / 2 +
          (d > a ? 0 : ((a < h - d ? 1 : (h - a) / d) * Z[(a - d) | 0]) / 2)
        : f)),
      (p = (c += v += z) * Math.sin(E * x - I)),
      (g += p - p * B * (1 - ((1e9 * (Math.sin(a) + 1)) % 2))),
      (E += p - p * B * (1 - ((1e9 * (Math.sin(a) ** 2 + 1)) % 2))),
      n && ++n > A && ((c += w), (D += w), (n = 0)),
      !l || ++J % l || ((c = D), (v = H), (n = n || 1));
  return Z;
};

// zzfxV - global volume
const zzfxV = 0.3;

// zzfxR - global sample rate
const zzfxR = 44100;

// zzfxX - the common audio context
const zzfxX = new (window.AudioContext || webkitAudioContext)();

//! ZzFXM (v2.0.3) | (C) Keith Clark | MIT | https://github.com/keithclark/ZzFXM
const zzfxM = (n, f, t, e = 125) => {
  let l,
    o,
    z,
    r,
    g,
    h,
    x,
    a,
    u,
    c,
    d,
    i,
    m,
    p,
    G,
    M = 0,
    R = [],
    b = [],
    j = [],
    k = 0,
    q = 0,
    s = 1,
    v = {},
    w = ((zzfxR / e) * 60) >> 2;
  for (; s; k++)
    (R = [(s = a = d = m = 0)]),
      t.map((e, d) => {
        for (
          x = f[e][k] || [0, 0, 0],
            s |= !!f[e][k],
            G = m + (f[e][0].length - 2 - !a) * w,
            p = d == t.length - 1,
            o = 2,
            r = m;
          o < x.length + p;
          a = ++o
        ) {
          for (
            g = x[o],
              u = (o == x.length + p - 1 && p) || (c != (x[0] || 0)) | g | 0,
              z = 0;
            z < w && a;
            z++ > w - 99 && u ? (i += (i < 1) / 99) : 0
          )
            (h = ((1 - i) * R[M++]) / 2 || 0),
              (b[r] = (b[r] || 0) - h * q + h),
              (j[r] = (j[r++] || 0) + h * q + h);
          g &&
            ((i = g % 1),
            (q = x[1] || 0),
            (g |= 0) &&
              (R = v[[(c = x[(M = 0)] || 0), g]] =
                v[[c, g]] ||
                ((l = [...n[c]]),
                (l[2] *= 2 ** ((g - 12) / 12)),
                g > 0 ? zzfxG(...l) : [])));
        }
        m = G;
      });
  return [b, j];
};

////////// sound //////////

// render functions run on engine init
// play sounds run at runtime

// store info about the type of each sound:
// 0 = ZzFXSound
// 1 = ZzFXMSong
// 2 = FileSound (wav, mp3)
let soundTypes = [];

// check that the sound exists and return its type
export function checkSoundType(id) {
  if (soundTypes[id] || soundTypes[id] === 0) {
    return new $Ok(soundTypes[id]);
  } else {
    return new $Error(null);
  }
}

async function renderZzFXMSong(source, i) {
  const songFile = await fetch(source);
  const songText = await songFile.text();
  const songData = JSON.parse(
    songText
      .replace(/\[,/g, "[null,")
      .replace(/,,\]/g, ",null]")
      .replace(/,\s*(?=[,\]])/g, ",null")
      .replace(/([\[,]-?)(?=\.)/g, "$10")
      .replace(/-\./g, "-0."),
    (_key, value) => (value === null ? undefined : value)
  );
  const songBuffer = zzfxM(...songData);
  sounds[i] = songBuffer;
  soundTypes[i] = 1;
}

async function renderZzFXSound(source, i) {
  const soundFile = await fetch(source);
  const soundText = await soundFile.text();
  const soundData = JSON.parse(
    soundText
      .replace(/\[,/g, "[null,")
      .replace(/,,\]/g, ",null]")
      .replace(/,\s*(?=[,\]])/g, ",null")
      .replace(/([\[,]-?)(?=\.)/g, "$10")
      .replace(/-\./g, "-0."),
    (_key, value) => (value === null ? undefined : value)
  );
  const soundBuffer = zzfxG(...soundData);
  sounds[i] = soundBuffer;
  soundTypes[i] = 0;
}

// Play a song by id from the sounds
export async function playZzFXMSong(id) {
  if (!sounds[id]) {
    throw new Error(`Song "${id}" not found in the library.`);
  }
  stopSound(); // Stop any currently playing song
  const buffer = sounds[id];
  const node = zzfxP(...buffer);
  node.loop = false;
  await zzfxX.resume();
  sounds._currentNode = node; // Store the current playing node
}

// Stop the currently playing song
export async function stopSound() {
  const currentNode = sounds._currentNode;
  if (currentNode) {
    await zzfxX.suspend();
    currentNode.stop();
    currentNode.disconnect();
    sounds._currentNode = null;
  }
}

export function playZzFXSound(id) {
  zzfxP(sounds[id]);
}

async function renderFileSound(source, i) {
  const response = await fetch(source);
  const audioData = await response.arrayBuffer();
  sounds[i] = await zzfxX.decodeAudioData(audioData);
  soundTypes[i] = 2;
}

export async function playFileSound(id) {
  stopSound();
  await zzfxX.resume();
  const source = zzfxX.createBufferSource();
  source.buffer = sounds[id];
  source.connect(zzfxX.destination);
  source.start(0);
  sounds._currentNode = source;
}
