# `<png>` — png

Install: `jget -li install png`   Use: `#import <png>`



## About (the header of the library)

```
png 0.1.0 -- reads PNG pictures.   #import <deflate>   #import <png>   (needs jcmp 1.2.1.0; license: MPL-2.0)
bool ok; Image im = Png::decode(Fs::read_bytes("hero.png").unwrap(), @ok);   im.w, im.h, im.px (4 bytes for each dot: red, green, blue, alpha)
All the kinds of PNG without interlacing: grey, grey + alpha, red green blue, with alpha, and palettes (also tRNS), 1 to 16 bits for each part (16 bits are cut to 8).
A picture with Adam7 interlacing gives ok = false (it comes later). The bytes live in a String (a byte is s[i] & 255).
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Image`

| call | gives | what it does |
|---|---|---|
| `x.red(int x, int y)` | `int` | one part of the dot (x, y), 0 to 255 |
| `x.green(int x, int y)` | `int` |  |
| `x.blue(int x, int y)` | `int` |  |
| `x.alpha(int x, int y)` | `int` |  |
### `Png`

| call | gives | what it does |
|---|---|---|
| `Png::decode(String data, bool^ ok)` | `Image` |  |
