# Lesson: `<simd>` - four numbers in one step

**Install:** `jc lib install simd`   **Use:** `#import <simd>`

One NEON register holds 128 bits: two doubles, four floats or whole numbers, or sixteen bytes. An operation on a vector works on every lane at once.

## Syntax
| type | lanes | notes |
|---|---|---|
| `f64x2` | 2 doubles | `.x .y` |
| `f32x4` | 4 floats | `.x .y .z .w` |
| `i32x4` | 4 whole numbers (32 bit) | `a + b`, `a - b`, `a * b` |
| `i8x16` | 16 bytes | `a + b`, `a - b`, `a.dot(b)` gives an `i32x4` |

| call | what it does |
|---|---|
| `T::load(@a[0], i)` | the lanes from the array `a`, starting at element `i` |
| `v.store(@a[0], i)` | write the lanes back |
| `v.sum()`, `v.min()`, `v.max()` | one number from all the lanes (for the whole-number and float types that have them) |
| `a + b`, `a - b`, `a * b` | lane by lane |

## Step 1: add four floats at once
```jk
#import <stdlib>
#import <simd>

int main() {
    float[] a = arr(8);
    float[] b = arr(8);
    float[] c = arr(8);
    for i in 0..8 { a.push((float) i); b.push(10.0); c.push(0.0); }
    f32x4 x = f32x4::load(@a[0], 0);
    f32x4 y = f32x4::load(@b[0], 0);
    f32x4 z = x + y;
    z.store(@c[0], 0);
    cout << c[0] << " " << c[1] << " " << c[2] << " " << c[3] << "\n";    // 10 11 12 13
    return 0;
}
```

## Step 2: a sum of a long array, four lanes a step
```jk
#import <stdlib>
#import <simd>

int main() {
    int n = 1000;
    float[] a = arr(n);
    for i in 0..n { a.push(0.5); }
    f32x4 acc = f32x4::load(@a[0], 0) - f32x4::load(@a[0], 0);      // four zeros
    int i = 0;
    while i + 4 <= n {
        acc = acc + f32x4::load(@a[0], i);
        i += 4;
    }
    cout << acc.sum() << "\n";                                      // 500
    return 0;
}
```
The scalar loop adds one number a step; this one adds four. The sum of four partial sums can differ in the last digit from the scalar sum.

## Step 3: bytes and the dot product
`i8x16.dot` multiplies sixteen pairs of bytes and adds each group of four: four sums in one instruction (`sdot`). Neural networks with quantised weights use it.
```jk
#import <stdlib>
#import <simd>

int main() {
    i8[] a = arr(16);
    i8[] b = arr(16);
    for i in 0..16 { a.push((i8) i); b.push(2); }
    i32x4 d = i8x16::load(@a[0], 0).dot(i8x16::load(@b[0], 0));
    cout << d.sum() << "\n";                  // 2 * (0 + 1 + ... + 15) = 240
    return 0;
}
```

## Exercises
1. Write `dot(float[] a, float[] b)` with `f32x4` and compare it with the plain loop.
2. Find the biggest number of an `int[]` of a million with `i32x4` and `max()`.
3. Scale a `float[]` by 2.0: load four, multiply, store four, and handle the last few numbers with a plain loop.
