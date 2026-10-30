# Lesson: `<neuron>` 2 - training a network

**Use:** `#import <neuron>`   Needs lesson 1.

One neuron draws a line. A **layer** is many neurons side by side (`x @ w + b`); put a bend (`tanh`, `relu`) between two layers and the network can learn curves and classes. XOR is the classic test: no single line separates the points.

## Syntax
| what | form |
|---|---|
| a layer | `Linear l = g.linear(inputs, outputs, seed);` (make it before `g.mark()`), `g.apply(l, x)` |
| learn | `g.sgd(rate)`, `g.adamw(rate, decay)` (a rate for each number, adjusted as it goes; `decay` 0.0 to 0.01), `g.clip(max)` (shrinks a gradient bigger than `max`, returns its size) |
| a batch | `g.acc_add()` after each `backward`, then `g.acc_apply(1.0 / n)` and `adamw`; or give many rows to one `matmul` |
| rate over time | `Sched::cosine(step, total, warm, lr, low)` (rises for `warm` steps, then falls like a cosine to `low`) |
| mixed order | `int[] order = shuffled(n, seed);`  `xs.gather(idx)` |
| classes | `g.softmax_ce(scores, int[] classes)`, then the class of a row is the place of its biggest score |
| save, load | `g.save(path)` (text), `g.load(path)` (the same parameters in the same order) |

## Step 1: XOR
```jk
#import <stdlib>
#import <neuron>

Graph g;

int main() {
    g = Graph::make();
    Linear l1 = g.linear(2, 8, 1);
    Linear l2 = g.linear(8, 1, 2);
    g.mark();
    double[] xv = arr(8);
    xv.push(0.0); xv.push(0.0); xv.push(0.0); xv.push(1.0); xv.push(1.0); xv.push(0.0); xv.push(1.0); xv.push(1.0);
    double[] yv = arr(4);
    yv.push(0.0); yv.push(1.0); yv.push(1.0); yv.push(0.0);
    Tensor32 xs = Tensor32::from_list(4, 2, xv);
    Tensor32 ys = Tensor32::from_list(4, 1, yv);
    double last = 0.0;
    for step in 0..400 {
        int h = g.tanh(g.apply(l1, g.input(xs)));
        int out = g.sigmoid(g.apply(l2, h));
        int loss = g.mse(out, ys);
        last = (double)g.value(loss).d[0];
        g.backward(loss);
        g.adamw(0.05, 0.0);
        g.clear();
    }
    int h2 = g.tanh(g.apply(l1, g.input(xs)));
    Tensor32 o = g.value(g.sigmoid(g.apply(l2, h2)));
    cout << "loss " << last << "\n";
    for i in 0..4 { cout << xs.get(i, 0) << " xor " << xs.get(i, 1) << " = " << o.get(i, 0) << "\n"; }
    return 0;
}
```

## Step 2: tell three groups apart (classes)
```jk
#import <stdlib>
#import <neuron>

Graph g;

int main() {
    g = Graph::make();
    int w = g.param(Tensor32::random(2, 3, 4, 0.5));
    int b = g.param(Tensor32::zeros(1, 3));
    g.mark();
    Tensor32 xs = Tensor32::zeros(30, 2);
    int[] cls = arr(30);
    double[] cx = arr(3);
    cx.push(0.0); cx.push(2.0); cx.push(-2.0);
    double[] cy = arr(3);
    cy.push(2.0); cy.push(-1.0); cy.push(-1.0);
    Tensor32 jitter = Tensor32::random(30, 2, 21, 0.4);          // the points are scattered around three centres
    for i in 0..30 {
        int c = i % 3;
        cls.push(c);
        xs.set(i, 0, cx[c] + jitter.get(i, 0));
        xs.set(i, 1, cy[c] + jitter.get(i, 1));
    }
    for step in 0..300 {
        int loss = g.softmax_ce(g.add(g.matmul(g.input(xs), w), b), cls);
        g.backward(loss);
        g.sgd(0.3);
        g.clear();
    }
    Tensor32 sc = g.value(g.add(g.matmul(g.input(xs), w), b));
    int right = 0;
    for i in 0..30 {
        int best = 0;
        for c in 1..3 { if sc.d[i * 3 + c] > sc.d[i * 3 + best] { best = c; } }
        if best == cls[i] { right += 1; }
    }
    cout << right << " of 30 points are put in the right group\n";
    return 0;
}
```

## Things to know
* If the loss does not fall: the learning rate is too big (it jumps) or too small; try AdamW at 0.01 to 0.05.
* A loss that falls on the data you train on but not on data you keep aside means the network only **remembers**: more data or a smaller network.
* Put the data in one big table and one `matmul` rather than many small ones: it is faster.

## Exercises
1. Teach the network AND and OR; does a network with no hidden layer learn XOR? (try `g.linear(2, 1, 1)` only).
2. Make a 5-class problem and report the share that is right.
3. Save the XOR model with `g.save("xor.model")`, start a new program, make the same layers, `g.load`, and check that it answers.

**Next:** lesson 3 (a language model), `<llama>` (models of others).
