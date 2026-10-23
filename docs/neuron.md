# `<neuron>` — tensors and small neural networks that train on the phone

Install: `jget -li install neuron`   Use: `#import <neuron>`

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
