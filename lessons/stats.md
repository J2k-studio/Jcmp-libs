# Lesson: `<stats>` - numbers about numbers

**Install:** `jc lib install stats`   **Use:** `#import <stats>`

A list of measurements is easier to understand when you know its middle and its spread. `Stats` works on a `double[]`.

## Syntax
| call | gives |
|---|---|
| `Stats::sum(xs)`, `Stats::mean(xs)` | the sum, the mean (0 for an empty list) |
| `Stats::min(xs)`, `Stats::max(xs)` | the smallest, the biggest |
| `Stats::variance(xs)`, `Stats::stddev(xs)` | how far the numbers are from the mean: the variance (of the whole list, divided by `n`) and its square root |
| `Stats::median(xs)` | the middle value (the mean of the two in the middle for an even count) |

## Step 1: the numbers of a list
```jk
#import <stdlib>
#import <stats>

int main() {
    double[] xs = arr(6);
    xs.push(2.0); xs.push(4.0); xs.push(4.0); xs.push(4.0); xs.push(5.0); xs.push(9.0);
    cout << "mean " << Stats::mean(xs) << ", median " << Stats::median(xs) << "\n";          // 4.666667, 4
    cout << "min " << Stats::min(xs) << ", max " << Stats::max(xs) << "\n";
    cout << "variance " << Stats::variance(xs) << ", stddev " << Stats::stddev(xs) << "\n";
    return 0;
}
```

## Step 2: the median ignores the odd one out
```jk
#import <stdlib>
#import <stats>

int main() {
    double[] pay = arr(5);
    pay.push(20000.0); pay.push(22000.0); pay.push(21000.0); pay.push(23000.0); pay.push(900000.0);
    cout << "mean   " << Stats::mean(pay) << "\n";          // dragged up by one number
    cout << "median " << Stats::median(pay) << "\n";        // 22000: what a typical person gets
    return 0;
}
```

## Step 3: how noisy is a sensor?
```jk
#import <stdlib>
#import <stats>

int main() {
    double[] reading = arr(20);
    int seed = 5;
    for i in 0..20 {
        seed = (seed * 1103515245 + 12345) & 2147483647;
        reading.push(20.0 + (double)(seed % 1000) / 500.0);       // 20 plus a noise of 0 to 2
    }
    double m = Stats::mean(reading);
    double s = Stats::stddev(reading);
    cout << "the reading is about " << m << " with a spread of " << s << "\n";
    int outliers = 0;
    for i in 0..reading.len { if reading[i] > m + 2.0 * s || reading[i] < m - 2.0 * s { outliers += 1; } }
    cout << outliers << " of 20 are more than two spreads away\n";
    return 0;
}
```

## Things to know
* `median` sorts a copy; the list you give is not changed.
* The variance here divides by `n`; for a sample of a bigger group many books divide by `n - 1`: multiply by `n / (n - 1)`.

## Exercises
1. Add `Stats` of a column of a CSV file (`<csv>` reads it).
2. Write `percentile(xs, p)` using a sorted copy.
3. Normalise a list: subtract the mean and divide by the spread, then check the new mean is 0.

**Next:** `<neuron>` (learning from numbers).
