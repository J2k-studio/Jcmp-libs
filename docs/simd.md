# `<simd>` — vectors of 2 or 4 numbers in one register (NEON)

Install: `jc lib install simd`   Use: `#import <simd>`

Several numbers are worked on by one instruction. The lanes are named x y z w.

## About (the header of the library)

```
simd: vectors of 2 or 4 numbers that live in one 128-bit register.   #import <simd>

f64x2 v = {1.0, 2.0};       v.x  v.y                      two doubles
i64x2 n = {1, 2};           n.x  n.y                      two 64-bit whole numbers
f32x4 f = {1.0, 2.0, 3.0, 4.0};   f.x f.y f.z f.w         four floats
i32x4 m = {1, 2, 3, 4};     m.x m.y m.z m.w               four 32-bit whole numbers

The lanes are named x y z w as in vec3. Steps S1-S3 of docs/syntax-design.md 59: the types, the operators, the loads and
stores of arrays (f64x2::load(a, i), v.store(a, i)).
```

## Example

```jk
#import <stdlib>
#import <simd>
void main() {
    f64x2 a = {1.0, 2.0};
    f64x2 b = {10.0, 20.0};
    f64x2 c = a + b * a;                 // both lanes at once: (1 + 10 * 1, 2 + 20 * 2)
    cout << c.x << " " << c.y << "\n";
    double data[4];
    data[0] = 1.0; data[1] = 2.0; data[2] = 3.0; data[3] = 4.0;
    f64x2 first = f64x2::load(@data, 0);  // two numbers from the array, starting at index 0
    f64x2 second = f64x2::load(@data, 2);
    f64x2 sum = first + second;
    cout << sum.x << " " << sum.y << "\n";
}
```

Output:

```
11.000000 42.000000
4.000000 6.000000
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `f64x2`

| call | gives | what it does |
|---|---|---|
| `f64x2::load(double^ p, int i)` | `f64x2` | two doubles from the array `p` starting at index i |
| `x.store(double^ p, int i)` | `void` | write the two lanes to an array |
| `x.sum()` | `double` | x + y |
| `x.min()` | `double` | the smaller lane |
| `x.max()` | `double` | the bigger lane |
### `i64x2`

| call | gives | what it does |
|---|---|---|
| `i64x2::load(int^ p, int i)` | `i64x2` | two whole numbers from an array |
| `x.store(int^ p, int i)` | `void` | write to an array |
| `x.sum()` | `int` | x + y |
| `x.min()` | `int` | the smaller lane |
| `x.max()` | `int` | the bigger lane |
### `f32x4`

| call | gives | what it does |
|---|---|---|
| `f32x4::load(float^ p, int i)` | `f32x4` | four floats from an array |
| `x.store(float^ p, int i)` | `void` | write to an array |
| `x.sum()` | `float` | the sum of the four |
| `x.min()` | `float` | the smallest |
| `x.max()` | `float` | the biggest |
### `i32x4`

| call | gives | what it does |
|---|---|---|
| `i32x4::load(i32^ p, int i)` | `i32x4` | four 32-bit numbers from an array |
| `x.store(i32^ p, int i)` | `void` | write to an array |
| `x.sum()` | `i32` | the sum of the four |
| `x.min()` | `i32` | the smallest |
| `x.max()` | `i32` | the biggest |

## i8x16 (0.10.0)

Sixteen `i8` lanes in one register, made for quantised numbers (neural networks, sound).

| call | gives | what it does |
|---|---|---|
| `i8x16::load(@a[0], i)` | `i8x16` | sixteen bytes from an array, starting at element i |
| `x.store(@a[0], i)` | `void` | write sixteen bytes |
| `a.dot(b)` | `i32x4` | four sums of four products (`sdot`): lane k = a[4k..4k+3] * b[4k..4k+3] |

```
#import <simd>
int main() {
    i8[] a = arr(16);
    i8[] b = arr(16);
    for i in 0..16 { a.push((i8) i); b.push(2); }
    i32x4 d = i8x16::load(@a[0], 0).dot(i8x16::load(@b[0], 0));
    cout << d.sum() << "\n";        // 240
    return 0;
}
```
