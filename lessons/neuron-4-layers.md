# Lesson: `<neuron>` 4 - layers for text and pictures

**Use:** `#import <neuron>`

Beyond `matmul` and the bends, the library has the pieces of today's networks, each with a gradient that is checked against a numeric difference.

## Syntax: the nodes of a `Graph`
| node | form | what it does |
|---|---|---|
| embedding | `g.embed(table, int[] ids)` | one row of the table (a parameter `vocab x width`) for every token number |
| norms | `g.layer_norm(x, gain, bias)`, `g.rms_norm(x, gain)` | every row is brought to the same scale (`gain`, `bias`: parameters of one row) |
| attention | `g.attention(q, k, v, heads)` | causal self-attention of one sequence: position `i` sees the positions `0..i`; the width is split into `heads` parts |
| convolution | `g.conv2d(x, w, b, c_in, h, w_in, c_out, k, stride, pad)` | a picture is one row of `channels x height x width` numbers; `w` is a parameter of `c_out` rows of `c_in*k*k` numbers; `b` one row of `c_out` |
| pooling | `g.maxpool(x, c, h, w, k)` | the biggest number of every `k x k` square |
| bends | `g.gelu`, `g.silu`, `g.tanh`, `g.sigmoid`, `g.relu` | |

## Step 1: a small picture network (a horizontal, a vertical or a diagonal bar)
```jk
#import <stdlib>
#import <neuron>

Graph g;

// pictures of 8 x 8 numbers: a bar on a noisy ground; kind 0 horizontal, 1 vertical, 2 diagonal
void draw(Tensor32 t, int row, int kind, int shift, int seed) {
    Tensor32 noise = Tensor32::random(1, 64, seed, 0.15);
    for i in 0..64 { t.d[row * 64 + i] = noise.d[i]; }
    for i in 0..8 {
        int r = shift;
        int c = i;
        if kind == 1 { r = i; c = shift; }
        if kind == 2 { r = i; c = (i + shift) % 8; }
        t.d[row * 64 + r * 8 + c] += 1.0;
    }
}

int main() {
    g = Graph::make();
    int cw = g.param(Tensor32::random(4, 9, 1, 0.5));            // 4 filters of 3 x 3
    int cb = g.param(Tensor32::zeros(1, 4));
    Linear fc = g.linear(4 * 4 * 4, 3, 2);                       // after the pooling: 4 channels of 4 x 4
    g.mark();
    Tensor32 pics = Tensor32::zeros(60, 64);
    int[] cls = arr(60);
    for i in 0..60 { draw(pics, i, i % 3, (i / 3) % 8, 100 + i); cls.push(i % 3); }
    for step in 0..120 {
        int c = g.relu(g.conv2d(g.input(pics), cw, cb, 1, 8, 8, 4, 3, 1, 1));
        int p = g.maxpool(c, 4, 8, 8, 2);
        int loss = g.softmax_ce(g.apply(fc, p), cls);
        g.backward(loss);
        g.adamw(0.02, 0.0);
        g.clear();
    }
    int pc = g.relu(g.conv2d(g.input(pics), cw, cb, 1, 8, 8, 4, 3, 1, 1));
    Tensor32 sc = g.value(g.apply(fc, g.maxpool(pc, 4, 8, 8, 2)));
    int hit = 0;
    for i in 0..60 {
        int best = 0;
        for c in 1..3 { if sc.d[i * 3 + c] > sc.d[i * 3 + best] { best = c; } }
        if best == cls[i] { hit += 1; }
    }
    cout << hit << " of 60 pictures are right\n";
    return 0;
}
```

## Step 2: one block of a language model by hand
```jk
#import <stdlib>
#import <neuron>

Graph g;

int main() {
    g = Graph::make();
    int emb = g.param(Tensor32::random(10, 8, 1, 0.3));           // 10 tokens, width 8
    int pos = g.param(Tensor32::random(6, 8, 2, 0.3));            // 6 positions
    int gain = g.param(Tensor32::zeros(1, 8));
    for i in 0..8 { g.value(gain).d[i] = 1.0; }
    Linear wq = g.linear(8, 8, 3);
    Linear wk = g.linear(8, 8, 4);
    Linear wv = g.linear(8, 8, 5);
    g.mark();
    int[] ids = arr(6);
    int[] places = arr(6);
    for i in 0..6 { ids.push(i % 10); places.push(i); }
    int x = g.add(g.embed(emb, ids), g.embed(pos, places));
    int n = g.rms_norm(x, gain);
    int att = g.attention(g.apply(wq, n), g.apply(wk, n), g.apply(wv, n), 2);     // 2 heads of width 4
    int out = g.add(x, att);                                      // the residual connection: add what came in
    Tensor32 r = g.value(out);
    cout << r.rows() << " x " << r.cols() << " numbers come out\n";
    return 0;
}
```

## Things to know
* A `width / heads` that is not a multiple of 4 makes attention slower (the fast kernel needs 4).
* `conv2d` and `maxpool` take the picture as **one row per picture** (`channels * height * width`), channel by channel.
* The tests of the library check every gradient: you can do the same for a new idea (change a number by 0.001 both ways).

## Exercises
1. Change the pooling to `k = 4` and make the `fc` layer fit; does the accuracy change?
2. Add a second convolution layer.
3. Give the block of step 2 a feed-forward part (`g.gelu(g.apply(up, n))` and `g.apply(down, ...)`) and add it back to `x`.

**Next:** `Gpt` (lesson 3) is these pieces put together; `<llama>` runs the same pieces from a file.
