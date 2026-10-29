# `<qr>` — qr

Install: `jc lib install qr`   Use: `#import <qr>`



## About (the header of the library)

```
qr 0.1.0 -- reads QR codes from a picture (a photo from the camera, a screenshot): the dots in, the text out.   #import <qr>   (license: MPL-2.0)
bool ok; String text = Qr::scan(im.px, im.w, im.h, @ok);        // im.px: 4 bytes for each dot, red green blue alpha (the Image of <png>)
ok = false: no code was found or it could not be read (Qr::error() says which)
Versions 1 to 40, the four levels of error correction (Reed-Solomon, mistakes are repaired), the modes numeric, alphanumeric and bytes (UTF-8 text),
any turning, a tilt that a flat sheet gives (a straight-on view with a little tilt), the light of a photo (a local threshold).
Not yet: mirrored codes, white on black, Kanji mode, the strong perspective of a code seen from the side.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Qr`

| call | gives | what it does |
|---|---|---|
| `Qr::error()` | `String` |  |
| `Qr::scan(String px, int w, int h, bool^ ok)` | `String` |  |
