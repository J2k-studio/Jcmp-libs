#!/usr/bin/env python3
"""gendocs.py: writes docs/NAME.md for every library of libs/ from its header comment, its functions and examples/NAME.jk (+ the output of the example).
Run it from the root of the repository:  python3 tools/gendocs.py  [--jcmp path-to-jcmp]"""
import os, re, subprocess, sys
jcmp = sys.argv[sys.argv.index("--jcmp") + 1] if "--jcmp" in sys.argv else "jcmp"
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
libs = os.path.join(root, "libs")
env = dict(os.environ, J2K_PATH=libs)
TMP = os.environ.get("TMPDIR", "/tmp")
DYN = {"native", "opengl3", "vulkan"}
ABOUT = {
 "simd": ("vectors of 2 or 4 numbers in one register (NEON)", "Several numbers are worked on by one instruction. The lanes are named x y z w."),
 "quat": ("rotations in 3D (quaternions)", "A quaternion turns a vector about an axis without the problems of angles."),
 "complex": ("complex numbers", "A number `re + im i` with the operators `+ - * /` and `abs`."),
 "stats": ("numbers about a list of numbers", "Sum, mean, minimum, maximum, variance, deviation and median of a `double[]`."),
 "canvas": ("drawing with characters, with a depth buffer", "A grid of characters; the nearest thing drawn in a place wins."),
 "screen": ("a picture of colour dots in the terminal", "Two dots share one character cell (half blocks), 24-bit colour."),
 "neuron": ("tensors and small neural networks that train on the phone", "A `Tensor` is a table of numbers; a `Network` is layers of neurons that learn with `fit`, answer with `predict` and keep their weights in a `.jw` text file."),
 "deflate": ("CRC-32, DEFLATE and gzip", "Compress and decompress data in memory, make and open `.gz` data."),
 "gamej": ("Jaric Engine: a small game engine", "The loop, input, time, 2D drawing, text, pictures made of letters, collision, sound and touch; in a terminal or on a surface in the Jaric app."),
 "gpu": ("the graphics chip through the Jaric app", "Commands for triangles, rectangles, lines, textures and tints are sent in one batch per picture; the app draws them with OpenGL ES."),
 "native": ("call the libraries of the system", "`dlopen`, `dlsym` and calls of C functions from J2K; the program must be built with `jcmp -dyn`."),
 "opengl3": ("OpenGL ES 3.1 / 2.0 on the real driver", "Off-screen drawing with shaders (GLSL), triangles, reading pixels and compute shaders on the graphics chip; build with `jcmp -dyn`."),
 "vulkan": ("Vulkan on the real driver (first step)", "An instance and the first chip: name, version, memory and queues; the rest of Vulkan is built with `native`; build with `jcmp -dyn`."),
}

D = {
 # canvas
 "Canvas.make": "a canvas of w x h characters (a character is about twice as high as wide)",
 "Canvas.free": "give the memory of the canvas back",
 "Canvas.clear": "empty the canvas: spaces, and the depth buffer reset",
 "Canvas.put": "put one character at (x, y)",
 "Canvas.get": "the character at (x, y)",
 "Canvas.text": "write a text from (x, y) to the right",
 "Canvas.plot": "draw a point p of 3D (vec3) with the character c; a nearer point wins",
 "Canvas.line": "a line between two points of 3D",
 "Canvas.ball": "a ball: the middle p, the radius r, shaded with the characters of `ramp` from dark to light",
 "Canvas.ball_lit": "the same, lit from the direction `to_light`",
 "Canvas.frame": "the picture as one String (lines separated by new lines)",
 "Canvas.clear_screen": "clear the terminal and move the cursor home",
 "Canvas.show": "print the picture on the terminal",
 # complex
 "cplx.make": "the number re + im i",
 "cplx.from_polar": "a number from its length r and its angle theta",
 "cplx.conj": "the conjugate: re - im i",
 "cplx.abs": "the length",
 "cplx.arg": "the angle",
 "cplx.exp": "e to the power of the number",
 "cplx.powi": "the number to the power of a whole number n",
 # deflate
 "Crc32.of": "the CRC-32 of the bytes of a String (the check number zip and gzip use)",
 "Deflate.compress": "compress the bytes of a String (raw DEFLATE, RFC 1951)",
 "Deflate.decompress": "open DEFLATE data; `ok[0]` is false when the data is damaged (pass `@ok`)",
 "Gzip.pack": "a .gz (RFC 1952) of the bytes of a String: header, DEFLATE, CRC-32, length",
 "Gzip.unpack": "open a .gz; the CRC and the length are checked; `ok` (pass `@ok`) is false when the data is bad",
 # gamej
 "Key.up": "the code of the arrow up (for `held` and `hit`)", "Key.down": "the code of the arrow down", "Key.right": "the code of the arrow right", "Key.left": "the code of the arrow left", "Key.space": "the code of the space key", "Key.enter": "the code of Enter", "Key.esc": "the code of Esc (it also ends the game)",
 "Game.rgb": "a colour from red, green, blue (0 to 255 each) as 0xRRGGBB",
 "Game.open": "start the game: the whole terminal is the screen (a surface of 160 x 90 pixels in the Jaric app)",
 "Game.running": "true until the game is ended (Esc, Ctrl-C, `quit`, the back key)",
 "Game.quit": "end the game after this turn",
 "Game.set_fps": "turns per second (default 60)",
 "Game.close": "give the terminal back (call it at the end)",
 "Game.note_key": "(internal) record that a key was seen",
 "Game.begin": "start a turn: read the keys and touches, measure `g.dt` (seconds since the last turn)",
 "Game.touching": "true while a finger is on the screen (the Jaric app); `g.touch_x`, `g.touch_y` say where",
 "Game.tapped": "true in the turn when a finger touched the screen",
 "Game.hit": "true if the key was pressed since the last turn (once for each press)",
 "Game.held": "true if the key was pressed lately (0.18 s): a terminal sends no key release",
 "Game.clear": "fill the picture with one colour",
 "Game.pixel": "set one pixel",
 "Game.get": "the colour of a pixel (0 outside the picture)",
 "Game.rect": "a filled rectangle: x, y, width, height, colour",
 "Game.frame_rect": "the outline of a rectangle",
 "Game.line": "a line between two points",
 "Game.circle": "a filled circle: the middle and the radius",
 "Game.text": "write a text in the small 3 x 5 font (capitals, digits, signs); gives the x after the last letter",
 "Game.text_scaled": "the same, each dot `scale` pixels big",
 "Game.art": "a picture made of letters: rows separated by new lines, a legend `<letter>#RRGGBB` repeated; '.' and ' ' are empty",
 "Game.overlap": "true if two boxes (x, y, width, height) touch",
 "Game.sound": "play a sound file (the Jaric app)",
 "Game.end": "finish the turn: draw the picture (only what changed) and wait for the next turn",
 "Game.present": "(internal) draw the picture now",
 # gpu
 "Gpu.rgb": "an opaque colour 0xFFRRGGBB", "Gpu.rgba": "a colour with an alpha (0 clear, 255 solid)",
 "Gpu.open": "open a picture of w x h logical pixels (scaled to the screen); `ok()` is false when there is no app",
 "Gpu.ok": "true when the graphics chip can be used", "Gpu.running": "true until the game is ended", "Gpu.quit": "end after this turn", "Gpu.set_fps": "turns per second",
 "Gpu.load": "a png / jpeg file becomes the texture `id` (files of the game are found through JC_ASSETS)",
 "Gpu.clear": "clear the picture", "Gpu.tri": "a triangle with one colour", "Gpu.rect": "a rectangle", "Gpu.tri_colors": "a triangle with a colour at each corner (blended)",
 "Gpu.image": "draw a texture in a rectangle; `tint` multiplies the colours (white = as it is)", "Gpu.image_part": "draw a part of a texture (u0 v0 u1 v1 in millionths)",
 "Gpu.line": "a line of a width", "Gpu.circle": "a circle (made of triangles)",
 "Gpu.note_key": "(internal)", "Gpu.hit": "a key pressed since the last turn", "Gpu.held": "a key pressed lately", "Gpu.touching": "a finger is on the screen", "Gpu.tapped": "a finger touched the screen in this turn",
 "Gpu.begin": "start a turn: touches, keys, `dt`", "Gpu.end": "send the commands of the turn to the chip and wait for the next turn", "Gpu.close": "close the picture",
 # native
 "Native.open": "the handle of a library (`libvulkan.so` ...), 0 if it is not there or the program was not built with `-dyn`",
 "Native.sym": "the address of a function of a library, 0 if none",
 "Native.call0": "call a C function (an address) with no argument", "Native.call1": "... with 1 whole number or pointer", "Native.call2": "... with 2", "Native.call3": "... with 3", "Native.call4": "... with 4", "Native.call5": "... with 5", "Native.call6": "... with 6", "Native.call7": "... with 7", "Native.call8": "... with 8 (the result is what the function returns in x0)",
 "Native.callf1": "call with 1 float argument", "Native.callf2": "with 2 floats", "Native.callf3": "with 3 floats", "Native.callf4": "with 4 floats (glClearColor)",
 "Native.calli_f1": "a whole number first, then 1 float (glUniform1f)", "Native.calli_f2": "... then 2 floats", "Native.calli_f3": "... then 3 floats", "Native.calli_f4": "... then 4 floats",
 "Native.text": "a String from the C text (ending with 0) at an address",
 "Native.peek8": "read 1 byte of memory", "Native.peek32": "read 32 bits", "Native.peek64": "read 64 bits", "Native.poke32": "write 32 bits", "Native.poke64": "write 64 bits",
 # neuron
 "Tensor.zeros": "a table of rows x cols numbers, all 0",
 "Tensor.get": "the number at row r, column c", "Tensor.set": "put a number at row r, column c",
 "Tensor.matmul": "the matrix product with another tensor", "Tensor.add": "add another tensor (one row is added to every row: the bias)",
 "Tensor.transpose": "rows and columns exchanged", "Tensor.relu": "negative numbers become 0", "Tensor.softmax": "every row becomes numbers that sum to 1",
 "Dense.make": "one layer: `inputs` numbers in, `outputs` neurons, random start (seed)", "Dense.forward": "the answer of the layer for x", "Dense.backward": "learn from the error `dy` of the answer (rate = the size of a step); gives the error for the layer before",
 "Network.make": "an empty network", "Network.add": "add a layer (relu between layers)", "Network.predict": "the answer of the network for x",
 "Network.step": "one round of learning on x and y; gives the loss", "Network.fit": "many rounds (`rounds`, `rate`); gives the last loss",
 "Network.text": "the weights as text", "Network.save": "write the weights to a .jw file", "Network.load": "read a network from a .jw file",
 # opengl3
 "Floats.make": "memory for `count` numbers of 32 bits (what the chip reads)", "Floats.set": "put a number", "Floats.get": "read a number",
 "Gl.fn": "the address of any OpenGL function by name (call it with Native::call1 .. call8)",
 "Gl.open": "an off-screen context: width, height, OpenGL ES version (3, 1 or 2, 0); `gl.ok`, `gl.log`, `gl.renderer`", "Gl.close": "release the context",
 "Gl.viewport": "glViewport", "Gl.clear_color": "glClearColor (red, green, blue, alpha from 0.0 to 1.0)", "Gl.clear_color_buffer": "paint the whole picture with the clear colour", "Gl.clear_all": "clear colour and depth",
 "Gl.enable": "glEnable", "Gl.disable": "glDisable", "Gl.blend_alpha": "turn on the blending of transparent colours", "Gl.finish": "wait until the chip has finished", "Gl.error": "glGetError (0 = no error)",
 "Gl.shader": "compile one shader (35633 vertex, 35632 fragment, 37305 compute); 0 and `gl.log` on a mistake",
 "Gl.program": "compile a vertex and a fragment shader and link them; 0 and `gl.log` on a mistake",
 "Gl.use": "make a program the one that draws", "Gl.uniform": "the place of a uniform variable of a program", "Gl.attrib": "the place of an input variable",
 "Gl.uniform1f": "set a float uniform", "Gl.uniform2f": "set a vec2", "Gl.uniform3f": "set a vec3", "Gl.uniform4f": "set a vec4", "Gl.uniform1i": "set an int uniform (a texture unit)", "Gl.uniform_matrix4": "set a 4 x 4 matrix (16 floats)",
 "Gl.gen_buffer": "a new buffer", "Gl.bind_buffer": "make a buffer the one in use (34962 array)", "Gl.buffer_data": "send the numbers of a Floats to the buffer in use",
 "Gl.vertex_attrib": "how the input variable `index` reads the buffer: size, stride and offset in floats", "Gl.draw_arrays": "draw (4 = triangles)",
 "Gl.draw_triangles": "send the corners (2 floats each) and draw triangles with the input 0", "Gl.read_pixels": "the pixels of a rectangle as bytes red, green, blue, alpha; the first row is the bottom",
 "Gl.compute": "run a compute shader (GLSL, OpenGL ES 3.1) on the numbers of a Floats in groups gx, gy, gz; gives the changed numbers",
 # quat
 "quat.make": "a quaternion from x, y, z, w", "quat.identity": "no rotation", "quat.from_axis_angle": "a turn of `angle` radians about an axis (a vec3)", "quat.conj": "the opposite turn (for a unit quaternion)",
 "quat.dot": "the dot product of two quaternions", "quat.length": "the length", "quat.normalize": "length 1 (a rotation must be normalized)", "quat.rotate": "turn a vec3", "quat.slerp": "a smooth mix between two rotations (t from 0 to 1)",
 # screen
 "Screen.make": "a picture of w x h dots (h even; two dots share a character)", "Screen.free": "give the memory back", "Screen.rgb": "pack red, green, blue into one number 0xRRGGBB",
 "Screen.clear": "fill with a colour", "Screen.set": "set a dot", "Screen.set_packed": "set a dot with a packed colour", "Screen.add": "add a colour to a dot (light adds up)", "Screen.get": "the packed colour of a dot",
 "Screen.blend": "mix a colour into a dot with an opacity a (0.0 to 1.0)", "Screen.line": "a line", "Screen.rect": "the outline of a rectangle", "Screen.fill_rect": "a filled rectangle",
 "Screen.circle": "the outline of a circle", "Screen.fill_circle": "a filled circle", "Screen.gradient_v": "a vertical gradient from one colour to another",
 "Screen.vignette": "darken the edges", "Screen.scanlines": "darken every second row", "Screen.brightness": "multiply all colours", "Screen.invert": "negative colours", "Screen.lit": "the number of dots that are not black", "Screen.glow": "a soft glow around the light dots",
 "Screen.frame": "the picture as text with the colour codes", "Screen.show": "print the picture", "Screen.begin": "clear the terminal and hide the cursor", "Screen.end": "show the cursor again",
 # simd
 "f64x2.load": "two doubles from the array `p` starting at index i", "f64x2.store": "write the two lanes to an array", "f64x2.sum": "x + y", "f64x2.min": "the smaller lane", "f64x2.max": "the bigger lane",
 "i64x2.load": "two whole numbers from an array", "i64x2.store": "write to an array", "i64x2.sum": "x + y", "i64x2.min": "the smaller lane", "i64x2.max": "the bigger lane",
 "f32x4.load": "four floats from an array", "f32x4.store": "write to an array", "f32x4.sum": "the sum of the four", "f32x4.min": "the smallest", "f32x4.max": "the biggest",
 "i32x4.load": "four 32-bit numbers from an array", "i32x4.store": "write to an array", "i32x4.sum": "the sum of the four", "i32x4.min": "the smallest", "i32x4.max": "the biggest",
 # stats
 "Stats.sum": "the sum", "Stats.mean": "the mean", "Stats.min": "the smallest", "Stats.max": "the biggest", "Stats.variance": "the variance of the whole list (divided by n)", "Stats.stddev": "the standard deviation", "Stats.median": "the middle value (the mean of the two middle ones if the number is even)",
 # vulkan
 "Vk.fn": "the address of a Vulkan function by name", "Vk.api_text": "the Vulkan version as text", "Vk.open": "make an instance and look at the first chip: `device_name`, `api_version`, `memory_mb`, `has_compute`, `queue_families`; `ok` and `log`", "Vk.close": "destroy the instance",
}

names = sorted(f[:-2] for f in os.listdir(libs) if f.endswith(".j"))
index = []
for n in names:
    src = open(os.path.join(libs, n + ".j")).read().split("\n")
    # the header comment: the first lines that start with //
    head = []
    for l in src:
        if l.startswith("//"): head.append(l[2:].strip())
        else: break
    # the reference
    ref = []
    cur = None
    prev_comment = []
    for l in src:
        m = re.match(r"^struct (\w+)", l)
        if m:
            cur = m.group(1)
            ref.append(("struct", cur, " ".join(prev_comment)))
            prev_comment = []
            continue
        mm = re.match(r"^    (static )?([\w<>\[\]\^]+) (\w+)\(([^)]*)\)", l)
        if mm and cur:
            static, ret, name, params = mm.groups()
            params = params.replace("self, ", "").replace("self", "").strip()
            trail = ""
            t = re.search(r"//\s*(.*)$", l)
            if t: trail = t.group(1)
            doc = D.get(cur + "." + name) or trail or " ".join(prev_comment)
            call = ("%s::%s(%s)" % (cur, name, params)) if static else ("x.%s(%s)" % (name, params))
            ref.append(("fn", call, ret, doc))
            prev_comment = []
            continue
        c = re.match(r"^\s*//\s?(.*)$", l)
        if c: prev_comment.append(c.group(1).strip())
        elif l.strip() == "" or l.startswith("}"): prev_comment = []
        else: prev_comment = []
    ex = os.path.join(root, "examples", n + ".jk")
    example = open(ex).read() if os.path.exists(ex) else ""
    out = ""
    if example:
        flags = ["-dyn"] if n in DYN else []
        r = subprocess.run([jcmp] + flags + [ex, "-o", ""+TMP+"/gendocs_" + n], capture_output=True, text=True, env=env)
        if r.returncode == 0:
            o = subprocess.run([""+TMP+"/gendocs_" + n], capture_output=True, text=True)
            out = o.stdout.replace("\x1b[H", "")
    title, about = ABOUT.get(n, (n, ""))
    version = ""
    mv = re.search(r"%s (\d+\.\d+\.\d+)" % n, " ".join(src[:2]))
    if mv: version = mv.group(1)
    md = ["# `<%s>` — %s" % (n, title), ""]
    md.append("Install: `jget -li install %s`   Use: `#import <%s>`%s" % (n, n, ("   Build the program with `jcmp -dyn`." if n in DYN else "")))
    md += ["", about, ""]
    md.append("## About (the header of the library)")
    md += ["", "```", *head, "```", ""]
    if example:
        md += ["## Example", "", "```jk", example.rstrip(), "```", ""]
        if out.strip():
            md += ["Output:", "", "```", out.rstrip(), "```", ""]
    md.append("## Reference")
    md.append("")
    md.append("Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.")
    md.append("")
    for item in ref:
        if item[0] == "struct":
            md.append("### `%s`" % item[1])
            md.append("")
            md.append("| call | gives | what it does |")
            md.append("|---|---|---|")
        else:
            md.append("| `%s` | `%s` | %s |" % (item[1], item[2], item[3]))
    md.append("")
    open(os.path.join(root, "docs", n + ".md"), "w").write("\n".join(md))
    index.append((n, title))
rows = ["| library | what it is |", "|---|---|"] + ["| [`<%s>`](%s.md) | %s |" % (n, n, t) for n, t in index]
open(os.path.join(root, "docs", "README.md"), "w").write("# The libraries of Jcmp-libs: how to use them\n\nEach page has what the library is, an example that runs (with its output) and the list of its functions.\n\n" + "\n".join(rows) + "\n")
print("wrote %d pages" % len(index))
