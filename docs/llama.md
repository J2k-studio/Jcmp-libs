# llama 0.1.0

Runs Llama-style language models from GGUF files on the CPU of the phone. `#import <llama>` (needs `gguf`, `neuron`).

```jk
switch Lm::load("stories15M-q4_0.gguf") {
    Result::Ok(m): {
        int[] ids = m.encode("Once upon a time");                  // token numbers, the start token first
        String text = m.generate(ids, 60, 0.8, 40, 0.95, 1);       // 60 new tokens: temperature, top-k (0 = off), top-p (1.0 = off), seed
        cout << text << "\n";
    }
    Result::Err(e): { cout << e.message << "\n"; }
}
```
Lower level: `m.reset()`, `Tensor32 logits = m.step(token)` (one token; the cache remembers the earlier ones), `m.sample(logits, temp, top_k, top_p)`, `m.piece(token)` (its text), `m.encode(text)`.

* Architecture `llama`: RMS norm, RoPE, grouped-query attention, SwiGLU, a KV cache; the context is cut at 512 tokens. Tied embeddings are handled.
* Tensors of type F32, F16, BF16, Q8_0 and Q4_0 are read and **dequantised to float32 when loaded** (a 15M model takes about 60 MB; a 1B model would take 4 GB, so only small models fit until the Q4 products are done without dequantising).
* The tokenizer is SentencePiece as llama.cpp does it (the sign ▁ for a space, joins with the best score, byte tokens as a fallback). Models with a BPE tokenizer (Llama 3, Qwen) are not supported yet.
* Speed on a Kirin 990 with plain loops: the 260K model writes 60 tokens in 0.1 s; `stories15M-q4_0` (15M parameters) about 11 tokens per second. Faster kernels are the next step.
* Models to try (small, free): `ggml-org/tiny-llamas` on Hugging Face (`stories260K.gguf`, `stories15M-q4_0.gguf`).
