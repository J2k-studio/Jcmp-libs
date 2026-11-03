# npu 0.1.0

A layer with **fixed weights** on the NPU of the phone, through NNAPI. `#import <npu>`.

| call | gives | what it does |
|---|---|---|
| `Npu::available()` | `bool` | NNAPI is there and has a device that is not the reference CPU |
| `NpuLinear::make(w, bias, m, k, n)` | `NpuLinear` | makes and compiles the model for `y = x * W^T + bias`: `w` is `n x k` numbers (row `i` = the weights of output `i`), `bias` is `n` numbers or `null`, `x` has `m` rows. About 70 ms |
| `l.ok`, `l.code` | | false and the NNAPI error (or -1: no NPU) when it did not work |
| `l.run(x, y)` | `bool` | `x`: `m x k` floats, `y`: `m x n` floats |
| `l.destroy()` | | free the model |

```
#import <npu>
int main() {
    if !Npu::available() { jout << "no NPU\n"; return 0; }
    // w: 256 x 256 floats, x: 64 x 256, y: 64 x 256 (filled by you)
    NpuLinear l = NpuLinear::make(w, null, 64, 256, 256);
    l.run(x, y);
    l.destroy();
    return 0;
}
```
Measured on a Kirin 990: 512 x 512 x 512 in 8.5 ms (the NEON CPU 37 ms, the GPU 15 ms); 256 in 4.6 ms; a call costs about 3 ms, so the NPU pays from about 8 rows and not for one row at a time. **Inference only**: the weights must be constants of the model (NNAPI refuses weights that are an input, error 4), so a model whose weights change at every step (training) cannot use it. The numbers are computed in half precision: values above 65504 overflow and about 3 decimal digits are good. Bigger than 512 was not tried. Without an NPU the program goes on with the CPU: `available()` is false.
