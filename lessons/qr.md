# Lesson: `<qr>` - reading QR codes from a picture

**Install:** `jc lib install deflate png qr`   **Use:** `#import <stdlib>`, `#import <files>`, `#import <deflate>`, `#import <png>`, `#import <qr>` and `using stdlib;` (the library uses the plain names of the standard library)   **Version:** 0.1.0

A QR code is a square of dark and light dots that holds text (an address, a Wi-Fi password, a payment). `Qr::scan` finds the code in a picture and gives the text. Versions 1 to 40, all four levels of error correction (damaged codes are repaired), numbers, letters and UTF-8 text, any turning and a small tilt, and the uneven light of a photo.

## Syntax
| what | form | gives |
|---|---|---|
| read | `Qr::scan(String px, int w, int h, bool^ ok)` | `String` (the text); `px` is 4 bytes a dot, red green blue alpha, as in an `Image` |
| why not | `Qr::error()` | the reason when `ok` is false (no code found, could not be read) |
Not yet: mirrored codes, white on black, Kanji mode, a strong perspective.

## Step 1: from a PNG file
```jk
#import <stdlib>
#import <files>
#import <deflate>
#import <png>
#import <qr>
using stdlib;

int main() {
    switch Fs::read_bytes("code.png") {
        Result::Ok(bytes): {
            bool ok = false;
            Image im = Png::decode(bytes, @ok);
            if !ok { cout << "cannot read the PNG\n"; return 1; }
            bool found = false;
            String text = Qr::scan(im.px, im.w, im.h, @found);
            if found { cout << "the code says: " << text << "\n"; }
            else { cout << "no code: " << Qr::error() << "\n"; }
        }
        Result::Err(e): { cout << e.message << "\n"; }
    }
    return 0;
}
```

## Step 2: from the camera
The tool `cam` (`jc install cam`) makes pictures and reads codes: `cam qr` scans from the camera. In your own program take the frame the camera gives (RGBA bytes) and give it to `Qr::scan` the same way.

## Things to know
* A big photo takes longer: the program looks for the three square marks first; a photo of 1000 x 1000 dots is read in a fraction of a second.
* A code that is read wrongly was probably blurred: get nearer, hold the phone steady, or light it.
* What the code says may be a link: do not open it without looking.

## Exercises
1. Scan a code from a screenshot and print only a text that starts with `http`.
2. Count how many codes are in a folder of pictures.
3. Make a program that reads a Wi-Fi code (`WIFI:T:WPA;S:name;P:password;;`) and prints the name and the password separately.

**Next:** `<png>`, `<canvas>`.
