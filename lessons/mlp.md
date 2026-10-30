# Lesson: `<mlp>` - a network in a few lines

**Install:** `jc lib install mlp` (it needs `neuron`)   **Use:** `#import <mlp>`

`Mlp` builds a network of dense layers, trains it with AdamW on shuffled batches, and keeps it in a file. The numbers are float32 (`Tensor32`).

## Syntax
| call | gives |
|---|---|
| `Mlp::make(sizes, act, seed)` | a network; `sizes` is `int[]` (inputs, hidden ..., outputs); `act` is `Mlp::RELU()`, `TANH()`, `SIGMOID()` or `GELU()` |
| `net.fit(x, y, epochs, lr)` | train to give the numbers `y` (mean squared error); returns the last loss |
| `net.fit_classes(x, labels, epochs, lr)` | train to find the class `labels[row]` (softmax cross entropy) |
| `net.predict(x)` | a `Tensor32` of outputs |
| `net.accuracy(x, labels)` | the part of the rows with the right class |
| `net.loss_on(x, y)` | the mean squared error |
| `net.save(path)`, `Mlp::load(path)` | keep and read the network |
| fields | `batch` (32), `decay`, `clip`, `every` (print the loss every n epochs), `cosine` (1: the rate falls along a cosine), `history` (the loss of each epoch) |

## Step 1: XOR
```jk
#import <stdlib>
#import <mlp>

int main() {
    Tensor32 x = Tensor32::zeros(4, 2);
    Tensor32 y = Tensor32::zeros(4, 1);
    x.d[2] = 1.0; x.d[5] = 1.0; x.d[6] = 1.0; x.d[7] = 1.0;       // rows 00 01 10 11
    y.d[1] = 1.0; y.d[2] = 1.0;                                   // 0 1 1 0
    int[] sizes = arr(3);
    sizes.push(2); sizes.push(8); sizes.push(1);
    Mlp net = Mlp::make(sizes, Mlp::TANH(), 3);
    net.batch = 4;
    net.fit(x, y, 600, 0.03);
    Tensor32 p = net.predict(x);
    cout << (p.d[0] < 0.3) << " " << (p.d[1] > 0.7) << " " << (p.d[2] > 0.7) << " " << (p.d[3] < 0.3) << "\n";    // true true true true
    return 0;
}
```

## Step 2: classes
```jk
#import <stdlib>
#import <mlp>

int main() {
    int n = 60;
    Tensor32 pts = Tensor32::zeros(n, 2);
    int[] labels = arr(n);
    for i in 0..n {
        int c = i % 2;
        pts.d[i * 2] = (float)(c * 3) + (float)(i % 5) * 0.1;
        pts.d[i * 2 + 1] = (float)(i % 7) * 0.1;
        labels.push(c);
    }
    int[] sizes = arr(3);
    sizes.push(2); sizes.push(8); sizes.push(2);
    Mlp net = Mlp::make(sizes, Mlp::RELU(), 1);
    net.fit_classes(pts, labels, 40, 0.02);
    cout << (net.accuracy(pts, labels) > 0.95) << "\n";          // true
    net.save("lesson.mlp");
    Mlp again = Mlp::load("lesson.mlp");
    cout << (again.accuracy(pts, labels) == net.accuracy(pts, labels)) << "\n";   // true
    return 0;
}
```

## Exercises
1. Make the network learn AND and OR with a hidden layer of 2.
2. Change `Mlp::RELU()` to `TANH()` and compare `net.history` after 40 epochs.
3. Read a CSV file with `Fs::read_text` and `split`, and train on its rows.
