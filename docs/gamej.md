# `<gamej>` — Jaric Engine: a small game engine

Install: `jget -li install gamej`   Use: `#import <gamej>`

The loop, input, time, 2D drawing, text, pictures made of letters, collision, sound and touch; in a terminal or on a surface in the Jaric app.

## About (the header of the library)

```
gamej 0.2.1 -- JARIC ENGINE, a small game engine for the terminal and the Jaric app.   #import <gamej>   (needs jcmp 1.1.0.0; license: MPL-2.0)
Game g = Game::open("Pong");                  // the whole terminal is the screen; each text cell is two pixels (half blocks, 24-bit colour)
while g.running() {
g.begin();                                // keys, the time since the last frame (g.dt, seconds)
if g.held(Key::left()) { x -= 40.0 * g.dt; }
g.clear(Game::rgb(16, 24, 32));
g.rect(10, 10, 8, 4, Game::rgb(255, 255, 255));    // x y w h colour (0xRRGGBB)
g.text(2, 2, "SCORE 12", Game::rgb(255, 220, 80));
g.end();                                  // draws the frame and waits for the next one (60 per second)
}
g.close();
Pixels: g.w x g.h. Draw: clear pixel rect frame line circle text art. Keys: hit(k) = pressed since the last frame, held(k) = pressed lately
(a terminal has no key-up message, so a held key is a key that repeated within 0.18 s; the keys row of the Jaric app gives single presses).
Esc and Ctrl-C end the game. GAME_FRAMES=N (environment) runs N frames without a terminal and stops (for tests).
Sound in the Jaric app: g.sound("file.mp3").
In the Jaric app the game draws on a SURFACE (a picture of g.w x g.h pixels, 160 x 90, drawn by the graphics chip and scaled to the screen) and
a touch comes as g.touching() / g.tapped() with g.touch_x, g.touch_y (in pixels). Elsewhere the terminal is the screen. GAMEJ_TERM=1 forces the terminal.
The back key of the app ends a game that has a surface.
```

## Example

```jk
#import <stdlib>
#import <gamej>
void main() {
    Game g = Game::open("example");                 // in a program that is not in a terminal it runs one turn and stops
    g.begin();
    g.clear(Game::rgb(10, 20, 40));
    g.rect(2, 2, 10, 6, Game::rgb(255, 200, 60));
    g.circle(30, 10, 4, Game::rgb(120, 220, 255));
    g.text(2, 20, "HELLO", Game::rgb(255, 255, 255));
    cout << g.get(3, 3) << " " << Game::overlap(0, 0, 5, 5, 4, 4, 5, 5) << "\n";   // the colour of a pixel; do two boxes touch
    g.end();
    g.close();
}
```

Output:

```
16762940 true
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Key`

| call | gives | what it does |
|---|---|---|
| `Key::up()` | `int` | the code of the arrow up (for `held` and `hit`) |
| `Key::down()` | `int` | the code of the arrow down |
| `Key::right()` | `int` | the code of the arrow right |
| `Key::left()` | `int` | the code of the arrow left |
| `Key::space()` | `int` | the code of the space key |
| `Key::enter()` | `int` | the code of Enter |
| `Key::esc()` | `int` | the code of Esc (it also ends the game) |
### `Game`

| call | gives | what it does |
|---|---|---|
| `Game::rgb(int r, int g, int b)` | `int` | a colour from red, green, blue (0 to 255 each) as 0xRRGGBB |
| `Game::open(String title)` | `Game` | start the game: the whole terminal is the screen (a surface of 160 x 90 pixels in the Jaric app) |
| `x.running()` | `bool` | true until the game is ended (Esc, Ctrl-C, `quit`, the back key) |
| `x.quit()` | `void` | end the game after this turn |
| `x.set_fps(int fps)` | `void` | turns per second (default 60) |
| `x.close()` | `void` | give the terminal back (call it at the end) |
| `x.note_key(int k, int now)` | `void` | (internal) record that a key was seen |
| `x.begin()` | `void` | start a turn: read the keys and touches, measure `g.dt` (seconds since the last turn) |
| `x.touching()` | `bool` | true while a finger is on the screen (the Jaric app); `g.touch_x`, `g.touch_y` say where |
| `x.tapped()` | `bool` | true in the turn when a finger touched the screen |
| `x.hit(int k)` | `bool` | true if the key was pressed since the last turn (once for each press) |
| `x.held(int k)` | `bool` | true if the key was pressed lately (0.18 s): a terminal sends no key release |
| `x.clear(int c)` | `void` | fill the picture with one colour |
| `x.pixel(int x, int y, int c)` | `void` | set one pixel |
| `x.get(int x, int y)` | `int` | the colour of a pixel (0 outside the picture) |
| `x.rect(int x, int y, int rw, int rh, int c)` | `void` | a filled rectangle: x, y, width, height, colour |
| `x.frame_rect(int x, int y, int rw, int rh, int c)` | `void` | the outline of a rectangle |
| `x.line(int x0, int y0, int x1, int y1, int c)` | `void` | a line between two points |
| `x.circle(int cx, int cy, int r, int c)` | `void` | a filled circle: the middle and the radius |
| `x.text(int x, int y, String s, int c)` | `int` | write a text in the small 3 x 5 font (capitals, digits, signs); gives the x after the last letter |
| `x.text_scaled(int x, int y, String s, int c, int scale)` | `int` | the same, each dot `scale` pixels big |
| `x.art(int x, int y, String rows, String legend)` | `void` | a picture made of letters: rows separated by new lines, a legend `<letter>#RRGGBB` repeated; '.' and ' ' are empty |
| `Game::overlap(int ax, int ay, int aw, int ah, int bx, int by, int bw, int bh)` | `bool` | true if two boxes (x, y, width, height) touch |
| `Game::allowed(String name)` | `bool` | The permissions of a program that jc started (JC_PERMS, with commas): a program started another way has all of them. |
| `x.sound(String path)` | `void` | play a sound file (the Jaric app) |
| `x.end()` | `void` | finish the turn: draw the picture (only what changed) and wait for the next turn |
| `x.present()` | `void` | (internal) draw the picture now |
