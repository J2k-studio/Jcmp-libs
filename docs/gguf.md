# gguf 0.1.0

A reader of GGUF model files (the format of llama.cpp and many model sites). `#import <gguf>` (needs `neuron`, for `Tensor32`).

```jk
switch Gg::open("model.gguf") {
    Result::Ok(f): {
        cout << f.meta("general.architecture") << " " << f.meta_int("llama.block_count", 0) << "\n";
        for i in 0..f.tensor_count() { cout << f.name(i) << " dims " << f.shape_text(i) << " " << f.type_name(i) << "\n"; }
        bool ok = false;
        Tensor32 w = f.load("token_embd.weight", @ok);      // float32; shape [ne1, ne0] = rows x width; ok is false for a missing name or a type not read
        // f.tokens (the vocabulary), f.merges (BPE merges), f.meta_double(key, fallback)
    }
    Result::Err(e): { cout << e.message << "\n"; }
}
```
* Versions 2 and 3. Metadata of every kind is kept as text (`meta`, `meta_int`, `meta_double`); arrays are skipped except `tokenizer.ggml.tokens` and `tokenizer.ggml.merges`.
* Tensor types read: F32, F16, BF16, Q8_0, Q4_0 (`supported(i)` tells). The others (Q4_K, Q5, Q6 ...) are listed but not loaded yet.
* The header is read into memory (up to 64 MB); a tensor is read from the file only when `load` is called, so a big model costs memory only for the tensors you use.
* Tested on a small file with all four tensor types, a Thai name, arrays, and a file that is not GGUF.
