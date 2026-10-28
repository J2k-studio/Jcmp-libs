# `<deflate>` — CRC-32, DEFLATE and gzip

Install: `jc lib install deflate`   Use: `#import <deflate>`

Compress and decompress data in memory, make and open `.gz` data.

## About (the header of the library)

```
deflate 0.1.0 -- CRC-32, DEFLATE (inflate + a compressor) and gzip.   #import <deflate>   (needs jcmp 1.1.0.0; license: MPL-2.0)
String z = Deflate::compress(data);   bool ok; String d = Deflate::decompress(z, ok);      // raw RFC 1951 bytes
String g = Gzip::pack(data);   String d2 = Gzip::unpack(g, ok);                             // .gz (RFC 1952), CRC checked
int c = Crc32::of(data);
Bytes live in a String (it may hold any byte); read a byte as  s[i] & 255.  The compressor uses LZ77 with the fixed codes.
```

## Example

```jk
#import <stdlib>
#import <deflate>
void main() {
    String text = "";
    for i in 0..100 { text.append("hello hello hello "); }
    String gz = Gzip::pack(text);                   // a .gz made in memory (write it with Fs::write_bytes to a file)
    bool ok = false;
    String back = Gzip::unpack(gz, @ok);            // ok is false when the data is damaged
    cout << text.len << " bytes -> " << gz.len << " bytes, back " << ok << " " << (back == text) << "\n";
    cout << Crc32::of("123456789") << "\n";
}
```

Output:

```
1800 bytes -> 39 bytes, back true true
3421780262
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Crc32`

| call | gives | what it does |
|---|---|---|
| `Crc32::of(String data)` | `int` | the CRC-32 of the bytes of a String (the check number zip and gzip use) |
### `Deflate`

| call | gives | what it does |
|---|---|---|
| `Deflate::compress(String data)` | `String` | compress the bytes of a String (raw DEFLATE, RFC 1951) |
| `Deflate::decompress(String z, bool^ ok)` | `String` | open DEFLATE data; `ok[0]` is false when the data is damaged (pass `@ok`) |
### `Gzip`

| call | gives | what it does |
|---|---|---|
| `Gzip::pack(String data)` | `String` | a .gz (RFC 1952) of the bytes of a String: header, DEFLATE, CRC-32, length |
| `Gzip::unpack(String g, bool^ ok)` | `String` | open a .gz; the CRC and the length are checked; `ok` (pass `@ok`) is false when the data is bad |
