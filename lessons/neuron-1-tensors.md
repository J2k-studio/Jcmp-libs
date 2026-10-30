# Lesson: `<neuron>` 1 - tensors and gradients

**Install:** `jc lib install neuron`   **Use:** `#import <neuron>`   **Version:** 0.7.0   (the tool `neuron` is built on it: `jc install neuron`)

A neural network is a pile of multiplications whose numbers are changed until the answers are right. To change them the right way you need the **gradient**: how much the error changes when a number changes. `<neuron>` has a table of numbers (`Tensor32`) and a recorder of the calculation (`Graph`) that finds all the gradients by going backwards.

## Syntax: `Tensor32` (float32 numbers in rows and columns)
| what | form |
|---|---|
| make | `Tensor32::zeros(rows, cols)`, `Tensor32::random(rows, cols, seed, scale)` (numbers from -scale to scale; the same seed gives the same numbers), `Tensor32::from_list(rows, cols, double[] v)` |
| read, write | `t.get(r, c)` and `t.set(r, c, v)` (doubles), `t.d[i]` (the float of place `i`, row after row), `t.rows()`, `t.cols()`, `t.size()` |
| calculate | `a.matmul(b)`, `a.add(b)` (`b` may be one row: added to every row), `a.mul(b)`, `a.scale(k)`, `a.transpose()`, `a.relu()`, `a.softmax()` (every row sums to 1), `a.sum()`, `a.mean()` |
| copy | `t.copy()`, `t.reshape(shape)`, `t.gather(int[] rows)` (some rows as a new table) |
The methods give new tables; the old ones do not change. `matmul` is fast (float32, NEON, threads for big tables).

## Syntax: `Graph` (the recorder)
| what | form |
|---|---|
| make | `Graph g = Graph::make();` (keep it in a **global**: it is big) |
| leaves | `g.param(Tensor32 t)` (a number that learns), `g.input(Tensor32 t)` (data); each gives a node number (`int`) |
| operations | `g.matmul(a, b)`, `g.add(a, b)`, `g.mul(a, b)`, `g.relu(a)`, `g.tanh(a)`, `g.sigmoid(a)`, `g.gelu(a)`, `g.silu(a)` |
| losses | `g.mse(a, Tensor32 target)` (mean of the squares of the errors), `g.softmax_ce(a, int[] classes)` (cross entropy of the rows against class numbers) |
| a step | `g.mark()` once after the parameters; then each step: build, `g.backward(loss)`, `g.sgd(rate)` (or `g.adamw`, lesson 2), `g.clear()` |
| look | `g.value(n)` (the `Tensor32` of a node), `g.gradient(n)` (after `backward`) |

## Step 1: the smallest learner (find y = 2x + 1)
```jk
#import <stdlib>
#import <neuron>

Graph g;

int main() {
    g = Graph::make();
    int w = g.param(Tensor32::zeros(1, 1));
    int b = g.param(Tensor32::zeros(1, 1));
    g.mark();                                       // the nodes so far are the parameters; the rest is made again each step
    double[] xv = arr(4);
    xv.push(0.0); xv.push(1.0); xv.push(2.0); xv.push(3.0);
    double[] yv = arr(4);
    yv.push(1.0); yv.push(3.0); yv.push(5.0); yv.push(7.0);
    Tensor32 xs = Tensor32::from_list(4, 1, xv);
    Tensor32 ys = Tensor32::from_list(4, 1, yv);
    for step in 0..300 {
        int guess = g.add(g.matmul(g.input(xs), w), b);
        int loss = g.mse(guess, ys);
        g.backward(loss);
        g.sgd(0.1);
        g.clear();
    }
    cout << "w = " << g.value(w).get(0, 0) << "  b = " << g.value(b).get(0, 0) << "\n";      // near 2 and 1
    return 0;
}
```

## Step 2: look at a gradient and check it by hand
The gradient says: change this number by a little and the loss changes by this much. You can test it with two evaluations.
```jk
#import <stdlib>
#import <neuron>

Graph g;

double loss_with(int w, Tensor32 xs, Tensor32 ys) {
    int l = g.mse(g.matmul(g.input(xs), w), ys);
    double v = (double)g.value(l).d[0];
    g.clear();
    return v;
}

int main() {
    g = Graph::make();
    Tensor32 start = Tensor32::zeros(1, 1);
    start.set(0, 0, 0.5);
    int w = g.param(start);
    g.mark();
    double[] xv = arr(3);
    xv.push(1.0); xv.push(2.0); xv.push(3.0);
    double[] yv = arr(3);
    yv.push(2.0); yv.push(4.0); yv.push(6.0);
    Tensor32 xs = Tensor32::from_list(3, 1, xv);
    Tensor32 ys = Tensor32::from_list(3, 1, yv);
    int l = g.mse(g.matmul(g.input(xs), w), ys);
    g.backward(l);
    double ana = (double)g.gradient(w).d[0];                        // the gradient from the graph
    float keep = g.value(w).d[0];
    g.value(w).d[0] = keep + 0.001;
    double up = loss_with(w, xs, ys);
    g.value(w).d[0] = keep - 0.001;
    double dn = loss_with(w, xs, ys);
    cout << "graph: " << ana << "   by two evaluations: " << (up - dn) / 0.002 << "\n";      // the same number
    return 0;
}
```

## Things to know
* **Loss** = how wrong; **learning rate** = the size of a step (too big: it jumps about; too small: it never arrives).
* `g.clear()` forgets the nodes of the step but keeps the parameters (the nodes before `mark()`).
* Gradients of the parameters add up over several `backward` calls only if you use `g.acc_add()` (a batch, lesson 2); otherwise each `backward` starts again.
* Numbers are float32: about 7 digits.

## Exercises
1. Fit `y = -3x + 4` and watch `w`, `b`.
2. Fit three points that are not on a line; what loss is left?
3. Change the learning rate to 1.0 and to 0.001 and see what happens.

**Next:** lesson 2 (layers, batches, AdamW), `<simd>` (how the matrix product is fast).
