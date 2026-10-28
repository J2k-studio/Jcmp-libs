// canvas2d 0.1.0 -- one interface for drawing 2D, so that a game is written once and runs on every graphics backend.   #import <canvas2d>   (license: MPL-2.0)
//   void draw_scene(Canvas2d^ c) {
//       c^.begin();  c^.clear(Color::rgb(10, 20, 40));
//       c^.rect(10.0, 10.0, 50.0, 30.0, Color::rgb(255, 200, 60));
//       c^.circle(100.0, 60.0, 20.0, Color::rgba(255, 255, 255, 128));
//       c^.line(0.0, 0.0, 100.0, 100.0, 2.0, Color::rgb(255, 0, 0));
//       c^.end();                                           // the frame is drawn here
//   }
// The backends (each one is a struct that says  impl Canvas2d ):  GlCanvas (OpenGL ES 3, <glcanvas>), AppCanvas (the commands of the Jaric app, <gpu>).
// Coordinates are dots of the surface: (0, 0) is the top left, y grows downwards. Colours are 0xAARRGGBB (Color::rgb is opaque).
// has_instancing() / has_shaders() tell what the backend can do, so that a game can choose a cheaper way where it cannot.

itf Canvas2d {
    void begin(self);
    void clear(self, int argb);
    void rect(self, double x, double y, double w, double h, int argb);
    void tri(self, double x0, double y0, double x1, double y1, double x2, double y2, int argb);
    void line(self, double x0, double y0, double x1, double y1, double width, int argb);
    void circle(self, double cx, double cy, double r, int argb);
    void end(self);
    bool has_instancing(self);
    bool has_shaders(self);
}

struct Color {
    static int rgb(int r, int g, int b) { return 0xff000000 | ((r & 255) << 16) | ((g & 255) << 8) | (b & 255); }
    static int rgba(int r, int g, int b, int a) { return ((a & 255) << 24) | ((r & 255) << 16) | ((g & 255) << 8) | (b & 255); }
}

