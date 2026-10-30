# Lesson: `<png>` - reading pictures

**Install:** `jc lib install deflate png`   **Use:** `#import <deflate>` and `#import <png>`   **Version:** 0.1.0

A PNG file is a picture packed with DEFLATE. `Png::decode` gives you the dots: for every dot four numbers 0-255 (red, green, blue, alpha = how solid it is). All kinds of PNG without interlacing are read (grey, colour, palettes, with or without alpha, 1 to 16 bits).

## Syntax
| what | form | gives |
|---|---|---|
| read | `Png::decode(String file_bytes, bool^ ok)` | `Image` (`ok` false for a damaged file or an interlaced one) |
| the picture | `im.w`, `im.h`, `im.px` | width, height, `w * h * 4` bytes row after row from the top |
| a dot | `im.red(x, y)`, `im.green(x, y)`, `im.blue(x, y)`, `im.alpha(x, y)` | `int` 0-255 |
The file bytes come from `Fs::read_bytes(path)` (a `Result<String, Error>`).

## Step 1: size and a corner
```jk
#import <stdlib>
#import <deflate>
#import <png>

int main() {
    switch Fs::read_bytes("hero.png") {
        Result::Ok(bytes): {
            bool ok = false;
            Image im = Png::decode(bytes, @ok);
            if !ok { cout << "not a PNG that can be read\n"; return 1; }
            cout << im.w << " x " << im.h << ", the first dot is "
                 << im.red(0, 0) << " " << im.green(0, 0) << " " << im.blue(0, 0) << " (alpha " << im.alpha(0, 0) << ")\n";
        }
        Result::Err(e): { cout << "cannot read the file: " << e.message << "\n"; }
    }
    return 0;
}
```

## Step 2: the average colour and a picture in text
```jk
#import <stdlib>
#import <deflate>
#import <png>

int main() {
    switch Fs::read_bytes("hero.png") {
        Result::Ok(bytes): {
            bool ok = false;
            Image im = Png::decode(bytes, @ok);
            if !ok { return 1; }
            int r = 0; int g = 0; int b = 0;
            for y in 0..im.h { for x in 0..im.w { r += im.red(x, y); g += im.green(x, y); b += im.blue(x, y); } }
            int n = im.w * im.h;
            cout << "average colour " << r / n << " " << g / n << " " << b / n << "\n";
            String ramp = " .:-=+*#%@";                                      // dark to light, 10 steps
            for row in 0..16 {
                String line = "";
                for col in 0..40 {
                    int x = col * im.w / 40;
                    int y = row * im.h / 16;
                    int light = (im.red(x, y) + im.green(x, y) + im.blue(x, y)) / 3;
                    line.push(ramp[light * 9 / 255]);
                }
                cout << line << "\n";
            }
        }
        Result::Err(e): { cout << e.message << "\n"; }
    }
    return 0;
}
```

## Things to know
* A big picture is a big `String` (4 bytes a dot): a 4000 x 3000 photo takes 48 MB.
* To show the picture in the app use `<gpu>` / `<canvas>`; to read a photo of a QR code use `<qr>`.
* Writing PNG is in the tool `imgj` (`jc install imgj`), which also reads JPEG.

## Exercises
1. Make a gray copy of the picture as numbers and print the darkest dot.
2. Count the dots that are fully see-through (`alpha == 0`).
3. Cut a rectangle out and print its size.

**Next:** `<qr>`, `<canvas>`, `<sprite>`.
