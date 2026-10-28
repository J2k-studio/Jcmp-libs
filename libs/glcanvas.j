// glcanvas 0.1.0 -- the Canvas2d interface on OpenGL ES 3: every shape of a frame goes into one buffer and is drawn with ONE call.   #import <opengl3> <canvas2d> <glcanvas>   (license: MPL-2.0)
//   Gl gl = Gl::open(320, 180, 3, 1);                      // off-screen; in an app: Gl::attach(w, h)
//   GlCanvas c; c.init(); c.setup(gl, 320.0, 180.0);       // sets the shader, the buffer and the size of the surface in dots
//   Canvas2d^ cv = @c;   cv^.begin(); cv^.rect(...); cv^.end();       // c.draws counts the draw calls of the last frame (1 for a whole frame)
// The batch holds 8192 triangles; when it is full it is drawn and started again (one more call).

struct GlCanvas impl Canvas2d {
    Gl gl;
    int prog;
    int vao;
    int vbo;
    int loc_size;
    Floats buf;
    int n;                          // floats in the batch
    int draws;                      // draw calls made by the last end()
    double w;
    double h;
    bool ready;
    int clear_color;
    bool wants_clear;

    void init(self) {
        self.n = 0;
        self.draws = 0;
        self.ready = false;
        self.wants_clear = false;
        self.clear_color = 0xff000000;
    }

    void setup(self, Gl gl, double w, double h) {
        self.gl = gl;
        self.w = w;
        self.h = h;
        String vs = "#version 300 es\nlayout(location = 0) in vec2 pos;\nlayout(location = 1) in vec4 col;\nuniform vec2 size;\nout vec4 v_col;\nvoid main() { v_col = col; gl_Position = vec4(pos.x / size.x * 2.0 - 1.0, 1.0 - pos.y / size.y * 2.0, 0.0, 1.0); }\n";
        String fs = "#version 300 es\nprecision mediump float;\nin vec4 v_col;\nout vec4 color;\nvoid main() { color = v_col; }\n";
        self.prog = gl.program(vs, fs);
        if self.prog == 0 { return; }
        self.loc_size = gl.uniform(self.prog, "size");
        self.buf = Floats::make(6 * 3 * 8192);
        self.vao = gl.gen_vertex_array();
        gl.bind_vertex_array(self.vao);
        self.vbo = gl.gen_buffer();
        gl.bind_buffer(34962, self.vbo);
        Native::call4(gl.fn("glBufferData"), 34962, self.buf.n * 4, 0, 35048);
        gl.vertex_attrib(0, 2, 6, 0);
        gl.vertex_attrib(1, 4, 6, 2);
        self.ready = true;
    }

    // one vertex: x, y, r, g, b, a (the colour as numbers from 0 to 1)
    void vertex(self, double x, double y, int argb) {
        if self.n + 6 > self.buf.n { self.flush(); }
        double a = (double)((argb >> 24) & 255) / 255.0;
        double r = (double)((argb >> 16) & 255) / 255.0;
        double g = (double)((argb >> 8) & 255) / 255.0;
        double b = (double)(argb & 255) / 255.0;
        self.buf.set(self.n, (float)x);
        self.buf.set(self.n + 1, (float)y);
        self.buf.set(self.n + 2, (float)r);
        self.buf.set(self.n + 3, (float)g);
        self.buf.set(self.n + 4, (float)b);
        self.buf.set(self.n + 5, (float)a);
        self.n += 6;
    }

    // send the batch to the chip and draw it
    void flush(self) {
        if self.n == 0 || !self.ready { self.n = 0; return; }
        self.gl.use(self.prog);
        self.gl.uniform2f(self.loc_size, self.w, self.h);
        self.gl.bind_vertex_array(self.vao);
        self.gl.bind_buffer(34962, self.vbo);
        Native::call4(self.gl.fn("glBufferSubData"), 34962, 0, self.n * 4, self.buf.ptr);
        self.gl.blend_alpha();
        self.gl.draw_arrays(4, 0, self.n / 6);
        self.draws += 1;
        self.n = 0;
    }

    void begin(self) {
        self.n = 0;
        self.draws = 0;
        self.gl.viewport(0, 0, (int)self.w, (int)self.h);
    }
    void clear(self, int argb) {
        self.flush();
        double a = (double)((argb >> 24) & 255) / 255.0;
        double r = (double)((argb >> 16) & 255) / 255.0;
        double g = (double)((argb >> 8) & 255) / 255.0;
        double b = (double)(argb & 255) / 255.0;
        self.gl.clear_color(r, g, b, a);
        self.gl.clear_color_buffer();
    }
    void rect(self, double x, double y, double w, double h, int argb) {
        self.vertex(x, y, argb);
        self.vertex(x + w, y, argb);
        self.vertex(x + w, y + h, argb);
        self.vertex(x, y, argb);
        self.vertex(x + w, y + h, argb);
        self.vertex(x, y + h, argb);
    }
    void tri(self, double x0, double y0, double x1, double y1, double x2, double y2, int argb) {
        self.vertex(x0, y0, argb);
        self.vertex(x1, y1, argb);
        self.vertex(x2, y2, argb);
    }
    // a line of the given width: a thin rectangle along the line
    void line(self, double x0, double y0, double x1, double y1, double width, int argb) {
        double dx = x1 - x0;
        double dy = y1 - y0;
        double len = Math::sqrt(dx * dx + dy * dy);
        if len < 0.000001 { return; }
        double nx = 0.0 - dy / len * width * 0.5;
        double ny = dx / len * width * 0.5;
        self.vertex(x0 + nx, y0 + ny, argb);
        self.vertex(x1 + nx, y1 + ny, argb);
        self.vertex(x1 - nx, y1 - ny, argb);
        self.vertex(x0 + nx, y0 + ny, argb);
        self.vertex(x1 - nx, y1 - ny, argb);
        self.vertex(x0 - nx, y0 - ny, argb);
    }
    // a fan of 32 triangles
    void circle(self, double cx, double cy, double r, int argb) {
        double step = 6.283185307179586 / 32.0;
        for i in 0..32 {
            double a0 = step * (double)i;
            double a1 = step * (double)(i + 1);
            self.vertex(cx, cy, argb);
            self.vertex(cx + r * Math::cos(a0), cy + r * Math::sin(a0), argb);
            self.vertex(cx + r * Math::cos(a1), cy + r * Math::sin(a1), argb);
        }
    }
    void end(self) { self.flush(); }
    bool has_instancing(self) { return true; }
    bool has_shaders(self) { return true; }
}

