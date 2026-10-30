# Lesson: `<deflate>` - packing bytes smaller (and gzip, and a checksum)

**Install:** `jc lib install deflate`   **Use:** `#import <deflate>`   **Version:** 0.1.0

Repeated bytes can be written shorter: "the cat sat, the cat ran" says "the cat " twice, the second time as "go back 12 places and copy 8". That is the idea of **DEFLATE**, the method inside `.zip`, `.gz` and `.png` files. The library packs and unpacks it, reads and writes `.gz`, and gives the **CRC-32** checksum that those formats use to see that no byte changed.

Bytes live in a `String` (a `String` may hold any byte); read a byte as `s[i] & 255`.

## Syntax
| what | form | gives |
|---|---|---|
| pack | `Deflate::compress(String data)` | `String` (raw DEFLATE, RFC 1951; the fixed codes of LZ77) |
| unpack | `Deflate::decompress(String z, bool^ ok)` | `String`; `ok` false when the data is damaged |
| gzip | `Gzip::pack(String data)`, `Gzip::unpack(String g, bool^ ok)` | a `.gz` file as a `String` (CRC checked) |
| checksum | `Crc32::of(String data)` | `int` (32 bits) |
Write `bool ok = false;` and pass `@ok`.

## Step 1: pack, look at the size, unpack
```jk
#import <stdlib>
#import <deflate>

int main() {
    String text = "";
    for i in 0..200 { text = text + "the cat sat on the mat. "; }
    String z = Deflate::compress(text);
    cout << text.len << " bytes became " << z.len << "\n";
    bool ok = false;
    String back = Deflate::decompress(z, @ok);
    cout << "unpacked ok " << ok << ", the same: " << (back == text) << "\n";
    return 0;
}
```

## Step 2: a `.gz` file that `gzip -d` can read
```jk
#import <stdlib>
#import <deflate>

int main() {
    String data = "";
    for i in 0..100 { data = data + "line " + str(i) + "\n"; }
    String g = Gzip::pack(data);
    Fs::write_bytes("lines.txt.gz", g);                 // then in the shell:  gzip -dc lines.txt.gz | head
    bool ok = false;
    String again = Gzip::unpack(g, @ok);
    cout << g.len << " bytes of gzip; unpacked " << again.len << " bytes, ok " << ok << "\n";
    return 0;
}
```

## Step 3: a damaged file is noticed
```jk
#import <stdlib>
#import <deflate>

int main() {
    String g = Gzip::pack("some data that matters to somebody");
    String bad = g.slice(0, 15) + "X" + g.slice(16, g.len);     // one byte changed in the middle
    bool ok = true;
    String s = Gzip::unpack(bad, @ok);
    cout << "damaged file: ok = " << ok << "\n";                // false: the CRC does not match
    cout << "crc of 'abc' = " << Crc32::of("abc") << "\n";       // 891568578 (0x352441C2)
    return 0;
}
```

## Things to know
* The compressor uses the fixed codes of DEFLATE: it is simple and fast, and packs a little less than `gzip -9`. Every decoder reads it.
* A `String` holds the whole file: for gigabytes unpack in pieces (not in this version).
* Text compresses 3-10 times; a file that is already packed (jpeg, mp3, zip) does not get smaller.

## Exercises
1. Pack a source file of yours and print the ratio.
2. Make a program `mygz FILE` that writes `FILE.gz`.
3. Find the shortest text that DEFLATE makes longer (a random byte string).

**Next:** `<png>` (a PNG file is DEFLATE inside), `<qr>`.
