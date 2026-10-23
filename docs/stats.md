# `<stats>` — numbers about a list of numbers

Install: `jget -li install stats`   Use: `#import <stats>`

Sum, mean, minimum, maximum, variance, deviation and median of a `double[]`.

## About (the header of the library)

```
Stats: numbers about a list of numbers (double[]). #import <math>   using math::stats;
double[] xs = arr(3);   xs.push(2.0);   xs.push(4.0);   xs.push(9.0);   double m = Stats::mean(xs);
```

## Example

```jk
#import <stdlib>
#import <math>
using math::stats;
void main() {
    double[] xs = arr(4);
    xs.push(2.0); xs.push(4.0); xs.push(4.0); xs.push(9.0);
    cout << Stats::mean(xs) << " " << Stats::median(xs) << " " << Stats::min(xs) << " " << Stats::max(xs) << "\n";
}
```

Output:

```
4.750000 4.000000 2.000000 9.000000
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Stats`

| call | gives | what it does |
|---|---|---|
| `Stats::sum(double[] xs)` | `double` | the sum |
| `Stats::mean(double[] xs)` | `double` | the mean |
| `Stats::min(double[] xs)` | `double` | the smallest |
| `Stats::max(double[] xs)` | `double` | the biggest |
| `Stats::variance(double[] xs)` | `double` | the variance of the whole list (divided by n) |
| `Stats::stddev(double[] xs)` | `double` | the standard deviation |
| `Stats::median(double[] xs)` | `double` | the middle value (the mean of the two middle ones if the number is even) |
