# Lesson: `<complex>` - numbers with an imaginary part

**Install:** `jc lib install complex`   **Use:** `#import <complex>`

A complex number is `re + im i` where `i * i = -1`. They describe things that turn: waves, signals, rotations in a plane, fractals (the Mandelbrot set is a loop of complex multiplications). `cplx` has the operators `+ - * /` and `==`, so you write formulas as you read them.

## Syntax
| what | form | gives |
|---|---|---|
| make | `cplx::make(double re, double im)`, `cplx::from_polar(double r, double theta)` | `cplx` (fields `a.re`, `a.im`) |
| operators | `a + b`, `a - b`, `a * b`, `a / b`, `-a`, `a == b` | `cplx` (`bool` for `==`) |
| size and angle | `a.abs()`, `a.arg()` | `double` (the angle is from -pi to pi) |
| other | `a.conj()` (the mirror image), `a.exp()`, `a.powi(int n)` (n >= 0) | `cplx` |

## Step 1: arithmetic
```jk
#import <stdlib>
#import <complex>

int main() {
    cplx a = cplx::make(1.0, 2.0);
    cplx b = cplx::make(3.0, -1.0);
    cplx s = a + b;                                  // 4 + 1i
    cplx p = a * b;                                  // (1*3 - 2*-1) + (1*-1 + 2*3)i = 5 + 5i
    cout << s.re << " + " << s.im << "i\n";
    cout << p.re << " + " << p.im << "i, size " << p.abs() << "\n";
    cplx i = cplx::make(0.0, 1.0);
    cplx m = i * i;
    cout << "i * i = " << m.re << " + " << m.im << "i\n";      // -1
    return 0;
}
```

## Step 2: the Mandelbrot set
A point `c` belongs to the set when `z = z * z + c`, started at 0, stays small for ever. We count the steps until it gets bigger than 2.
```jk
#import <stdlib>
#import <complex>

int steps(cplx c) {
    cplx z = cplx::make(0.0, 0.0);
    int n = 0;
    while n < 50 && z.abs() <= 2.0 {
        z = z * z + c;
        n += 1;
    }
    return n;
}

int main() {
    for row in 0..11 {
        String line = "";
        for col in 0..40 {
            cplx c = cplx::make(-2.2 + (double)col * 0.08, -1.0 + (double)row * 0.2);
            if steps(c) >= 50 { line.push('#'); } else { line.push('.'); }
        }
        cout << line << "\n";
    }
    return 0;
}
```

## Step 3: a rotation is a multiplication
```jk
#import <stdlib>
#import <math>
#import <complex>

int main() {
    cplx p = cplx::make(1.0, 0.0);
    cplx turn = cplx::from_polar(1.0, Math::pi() / 2.0);     // a quarter turn: size 1, angle 90 degrees
    cplx q = p * turn;                                       // (1, 0) turned a quarter: (0, 1)
    cout << q.re << " " << q.im << "\n";
    cplx r = turn.powi(4);                                   // four quarters: back to (1, 0)
    cout << r.re << " " << r.im << "\n";
    return 0;
}
```

## Things to know
* Doubles are not exact: `r.re` may print `0.999999` or `-0.000000`; compare with a small margin.
* `a.arg()` of `0` is 0 (there is no angle).

## Exercises
1. Print the 8 numbers `from_polar(1.0, 2 pi k / 8)` (the eighth roots of 1) and check that each to the power 8 is 1.
2. Colour the Mandelbrot picture with more characters (`' .:-=+*#%@'`) by the number of steps.
3. Write the Julia set: the same loop with a fixed `c` and a start `z` that moves with the point.

**Next:** `<quat>` (rotations in 3D), `<screen>` (draw the picture of the set).
