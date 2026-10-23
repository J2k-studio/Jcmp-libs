# `<complex>` — complex numbers

Install: `jget -li install complex`   Use: `#import <complex>`

A number `re + im i` with the operators `+ - * /` and `abs`.

## About (the header of the library)

```
cplx: a complex number re + im i. #import <math>   using math::complex;
cplx a = cplx::make(1.0, 2.0);   cplx b = a * a + cplx::make(0.0, 1.0);   double r = b.abs();
```

## Example

```jk
#import <stdlib>
#import <math>
using math::complex;
void main() {
    cplx a = cplx::make(1.0, 2.0);
    cplx b = a * a + cplx::make(0.0, 1.0);     // (1 + 2i)^2 + i = -3 + 5i
    cout << b.re << " " << b.im << "\n";
}
```

Output:

```
-3.000000 5.000000
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `cplx`

| call | gives | what it does |
|---|---|---|
| `cplx::make(double re, double im)` | `cplx` | the number re + im i |
| `cplx::from_polar(double r, double theta)` | `cplx` | a number from its length r and its angle theta |
| `x.conj()` | `cplx` | the conjugate: re - im i |
| `x.abs()` | `double` | the length |
| `x.arg()` | `double` | the angle |
| `x.exp()` | `cplx` | e to the power of the number |
| `x.powi(int n)` | `cplx` | the number to the power of a whole number n |
