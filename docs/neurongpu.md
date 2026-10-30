# neurongpu 0.1.0

The matrix product of `<neuron>` on the GPU. `#import <neurongpu>`.

| call | gives | what it does |
|---|---|---|
| `NeuronGpu::enable(min_work)` | `bool` | from now on `Tensor32.matmul` sends a product with `m * k * n >= min_work` to the GPU; false when there is no GPU |
| `NeuronGpu::disable()` | `void` | back to the CPU |

`Graph.matmul`, `Linear` and `Gpt` all call `Tensor32.matmul`, so one `enable` is enough.

```
#import <neuron>
#import <neurongpu>
int main() {
    NeuronGpu::enable(16000000);          // from 256 x 256 x 256 up
    // ... train as before ...
    return 0;
}
```

Measured on a Kirin 990 (square tables): 128: CPU 1.0 ms, GPU 0.6-1.2 ms; 256: 5.5 / 3.6 ms; 512: 37 / 15 ms. The small models of `Gpt` (d 64) stay on the CPU with this limit. The numbers are float32 on both sides; the last digits of a sum may differ. The shader works on any shape (tiles of 16 x 16, edges padded with zeros). A buffer is sent for each product; keeping the weights on the chip is the next step.
