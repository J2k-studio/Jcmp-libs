# `<glapp>` — glapp

Install: `jc lib install glapp`   Use: `#import <glapp>`



## About (the header of the library)

```
glapp 0.1.0 -- a game that is a shared library inside an Android app: the app (a GLSurfaceView) owns the screen and the OpenGL ES context
and calls the game on its GL thread.   #import <glapp>   build: jcmp game.jk -l -o libgame.so   (makej with  render = "gl"  in manifest.toml does it all)   (license: MPL-2.0)
The game defines four functions (glapp calls them; they are found by name):
void game_init(int w, int h)                   // the surface exists (w x h dots): load pictures, make things
void game_resize(int w, int h)                 // the surface changed (the phone turned)
void game_frame(int ms)                        // draw one frame; ms since the last one. Draw with  Canvas2d^ c = glapp_canvas();  or  glapp_gl()  directly
void game_touch(int action, int x, int y, int id)      // action 1 down, 2 move, 3 up (the same numbers as the Jaric app); x, y in dots of the surface
glapp_gl() is the Gl of the context the app made; glapp_canvas() the Canvas2d on it (<glcanvas>, ES 3 or ES 2); glapp_w() / glapp_h() the size.
The functions below (Java_com_j2k_gamerun_GameLib_*) are the JNI entry points of the class GameLib that the app has; do not call them.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

