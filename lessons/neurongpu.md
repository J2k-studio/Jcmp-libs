# Lesson: `<neurongpu>` - the matrix product on the graphics chip

**Install:** `jc lib install neurongpu` (it needs `neuron`)   **Use:** `#import <neuron>` then `#import <neurongpu>`

Training and running a network is mostly matrix products. The phone's GPU does a big product faster than the CPU, but sending the numbers to it costs time, so it pays only for big tables.

## Syntax
| call | gives |
|---|---|
| `NeuronGpu::enable(min_work)` | `true` when a GPU is there. From now on `Tensor32.matmul` uses it for products with `m * k * n >= min_work` |
| `NeuronGpu::disable()` | back to the CPU for everything |

`Graph.matmul`, `Linear` and `Gpt` call `Tensor32.matmul`, so one `enable` changes all of them. The answer is the same up to the last digits of a float32 sum.

## Step 1: the same product, CPU and GPU
```jk
#import <stdlib>
#import <neuron>
#import <neurongpu>

Tensor32 table(int r, int c) {
    int[] sh = arr(2);
    sh.push(r); sh.push(c);
    Tensor32 t = Tensor32::make(sh);
    for i in 0..r * c { t.d[i] = (float)((i * 3) % 13) * 0.125 - 0.5; }
    return t;
}

int main() {
    Tensor32 a = table(40, 33);
    Tensor32 b = table(33, 17);
    NeuronGpu::disable();
    Tensor32 cpu = a.matmul(b);
    bool gpu = NeuronGpu::enable(1);                   // 1: every product goes to the GPU
    Tensor32 g = a.matmul(b);
    double worst = 0.0;
    for i in 0..40 * 17 {
        double e = (double)(cpu.d[i]) - (double)(g.d[i]);
        if e < 0.0 { e = 0.0 - e; }
        if e > worst { worst = e; }
    }
    cout << "the difference is tiny: " << (worst < 0.001) << "\n";
    return 0;
}
```
The shapes do not have to be multiples of 16: the shader pads the edges with zeros.

## Step 2: choose the limit
A good limit on the Kirin 990 is 16000000 (a 256 x 256 x 256 product): there the GPU is 1.5 times faster, and at 512 x 512 it is 2.4 times faster. Below 128 the CPU is as fast or faster.
```jk
#import <stdlib>
#import <neuron>
#import <neurongpu>

int main() {
    if NeuronGpu::enable(16000000) {
        cout << "big products go to the GPU\n";
    } else {
        cout << "no GPU: the CPU does everything\n";
    }
    // ... train a network here: nothing else changes ...
    return 0;
}
```

## Exercises
1. Time a 512 x 512 product with and without the GPU (`Time::now_ms()`), five times each.
2. Find the size where the GPU starts to win on your phone.
3. Train the small `Gpt` of the lesson `neuron-3-gpt` with the GPU on and look at the time of a step: why does it not change?
