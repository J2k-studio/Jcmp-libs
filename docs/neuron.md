# `<neuron>` — tensors and small neural networks that train on the phone

Install: `jc lib install neuron`   Use: `#import <neuron>`

A `Tensor` is a table of numbers; a `Network` is layers of neurons that learn with `fit`, answer with `predict` and keep their weights in a `.jw` text file.

## About (the header of the library)

```
neuron 0.1.0 -- tensors and small neural networks that train on the phone.   #import <neuron>   (needs jcmp 1.1.0.0; license: MPL-2.0)
Tensor a = Tensor::zeros(2, 3);   a.set(0, 1, 5.0);   Tensor c = a.matmul(b);   Tensor p = c.relu().softmax();
Network n = Network::make();   n.add(2, 8);   n.add(8, 1);                // layers of neurons: relu between them
n.fit(x, y, 3000, 0.1);   Tensor out = n.predict(x);   n.save("m.jw");   Network m = Network::load("m.jw");
A Tensor is a table of rows x cols numbers (double); the methods return new Tensors. The file .jw is a text file (the weights).
```

## Example

```jk
#import <stdlib>
#import <math>
#import <neuron>
void main() {
    Tensor x = Tensor::zeros(4, 2);                 // 4 examples with 2 numbers each
    Tensor y = Tensor::zeros(4, 1);                 // the answer for each
    x.set(1, 1, 1.0); x.set(2, 0, 1.0); x.set(3, 0, 1.0); x.set(3, 1, 1.0);
    y.set(1, 0, 1.0); y.set(2, 0, 1.0);             // XOR: 0 0 -> 0, 0 1 -> 1, 1 0 -> 1, 1 1 -> 0
    Network n = Network::make();
    n.add(2, 8);                                    // a layer: 2 numbers in, 8 neurons
    n.add(8, 1);
    double loss = n.fit(x, y, 4000, 0.1);           // learn: 4000 rounds, rate 0.1
    Tensor out = n.predict(x);
    cout << (loss < 0.001) << " " << (out.get(1, 0) > 0.5) << " " << (out.get(3, 0) < 0.5) << "\n";
    n.save("xor.jw");                               // the weights go to a text file; Network::load("xor.jw") reads them back
}
```

Output:

```
true true true
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Tensor`

| call | gives | what it does |
|---|---|---|
| `Tensor::zeros(int rows, int cols)` | `Tensor` | a table of rows x cols numbers, all 0 |
| `x.get(int r, int c)` | `double` | the number at row r, column c |
| `x.set(int r, int c, double v)` | `void` | put a number at row r, column c |
| `x.matmul(Tensor o)` | `Tensor` | the matrix product with another tensor |
| `x.add(Tensor o)` | `Tensor` | add another tensor (one row is added to every row: the bias) |
| `x.transpose()` | `Tensor` | rows and columns exchanged |
| `x.relu()` | `Tensor` | negative numbers become 0 |
| `x.softmax()` | `Tensor` | every row becomes numbers that sum to 1 |
### `Dense`

| call | gives | what it does |
|---|---|---|
| `Dense::make(int inputs, int outputs, int seed)` | `Dense` | one layer: `inputs` numbers in, `outputs` neurons, random start (seed) |
| `x.forward(Tensor x)` | `Tensor` | the answer of the layer for x |
| `x.backward(Tensor dy, double rate)` | `Tensor` | learn from the error `dy` of the answer (rate = the size of a step); gives the error for the layer before |
### `Network`

| call | gives | what it does |
|---|---|---|
| `Network::make()` | `Network` | an empty network |
| `x.add(int inputs, int outputs)` | `void` | add a layer (relu between layers) |
| `x.predict(Tensor x)` | `Tensor` | the answer of the network for x |
| `x.step(Tensor x, Tensor y, double rate)` | `double` | one round of learning on x and y; gives the loss |
| `x.fit(Tensor x, Tensor y, int rounds, double rate)` | `double` | many rounds (`rounds`, `rate`); gives the last loss |
| `x.text()` | `String` | the weights as text |
| `x.save(String path)` | `bool` | write the weights to a .jw file |
| `Network::load(String path)` | `Network` | read a network from a .jw file |

## `Tensor.matmul_fast(o)` (0.2.0)
The same product as `matmul`, for big tables: the numbers are packed as float32 in rows of a multiple of 8, `o` is turned over so that every result is a dot product of two rows (NEON, 4 numbers at a time, two accumulators), and the rows of the result are shared among 4 threads. The last digits differ from `matmul` (float32 inside). Tables with `rows * cols * o.cols < 32768` use the plain loop. Needs `#import <simd>` (`jc lib install simd`).
```jk
Tensor c = a.matmul_fast(b);     // 256 x 256: 7 times faster than a.matmul(b) on a Kirin 990
```

## 0.3.0: `Tensor32` and `Graph` (float32 and autograd)
`Tensor32` keeps float32 numbers with a shape of up to 4 numbers (the last is the width of a row). The old `Tensor` (double) and `Network` stay.
```jk
Tensor32 a = Tensor32::random(64, 32, 1, 0.5);        // rows, cols, seed, scale
Tensor32 c = a.matmul(b);   a.add(bias_row);   a.mul(o);   a.scale(2.0);   a.transpose();   a.relu();   a.softmax();
a.sum(); a.mean(); a.get(r, c); a.set(r, c, v); a.copy(); a.reshape(shape)
```
`matmul` is the fast kernel (packed float32, dot products, 4 threads for big tables): 3.2 GFLOPS at 128x128 and 5.2 at 256x256 on a Kirin 990.

`Graph` is autograd with a tape (reverse mode). A node is an `int`.
```jk
Graph g = Graph::make();
int w = g.param(Tensor32::random(2, 6, 1, 1.0));   int b = g.param(Tensor32::zeros(1, 6));
g.mark();                                          // the nodes so far are the parameters
for step in 0..1000 {
    int h = g.tanh(g.add(g.matmul(g.input(xs), w), b));
    int loss = g.mse(h, ys);                       // or g.softmax_ce(scores, classes) with one class number per row
    g.backward(loss);   g.sgd(0.1);   g.clear();   // clear() keeps the parameters and throws the rest of the step away
}
```
Ops: `matmul`, `add` (same shape or one row = bias), `mul`, `relu`, `tanh`, `sigmoid`, `mse`, `softmax_ce`. `g.value(n)` and `g.gradient(n)` give the Tensor32 of a node. Every op's gradient is checked against a numeric difference in the tests; XOR and a 3-class problem train. Not yet: AdamW, layers (embedding, norm, attention, conv), GGUF (see the plan in the project: N3-N7).
