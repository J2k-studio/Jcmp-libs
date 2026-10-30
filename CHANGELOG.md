# Jcmp-libs changelog (what changed in the libraries, newest first)

## neuron 0.7.0 (2026-10-30)
* **Added:** `Gpt`, a GPT you train on the phone (`Gpt::make`, `step` on a batch, `loss_on`, `write`, `save`/`load`, byte level) with `examples/train_gpt.jk`; the tool `neuron gpt train` is built on it (part of `neuron`). `Graph.acc_add` / `acc_apply` (gradients of a batch), `Tensor32.matmul` 3-4 times faster for small tables (NEON, no packing), fast `exp` / `tanh` (about 15 multiplications instead of 100 ns), attention with NEON kernels (7 ms to 3 ms for a layer of 64 x 64).
* **Fixed:** none. (A function of the library must not have more than 8 parameters: the compiler does not warn yet.)

## neuron 0.6.0 (2026-10-30)
* **Added:** `Graph.conv2d` (window, stride, padding, channels) and `Graph.maxpool`, with gradients checked numerically; a conv network learns to tell three kinds of pictures apart.
* **Fixed:** none.

## llama 0.1.1 (2026-10-30)
* **Added:** the matrix-vector product uses NEON (four numbers at a time, two sums): `stories15M-q4_0` goes from 11 to 82 tokens per second on a Kirin 990 with the same text.
* **Fixed:** none.

## llama 0.1.0 (2026-10-30)
* **Added:** `llama`: runs Llama-style GGUF models: forward pass (RMS norm, RoPE, grouped-query attention, SwiGLU, KV cache), a SentencePiece tokenizer, greedy / temperature / top-k / top-p sampling. `stories15M-q4_0` writes coherent stories at about 11 tokens per second on a phone.
* **Fixed:** none.

## gguf 0.1.0 (2026-10-30)
* **Added:** `gguf`: reads GGUF model files: metadata, the vocabulary, merges and token scores, the list of tensors, and F32 / F16 / BF16 / Q8_0 / Q4_0 tensors as float32 `Tensor32`. First step of running real models on the phone.
* **Fixed:** none.

## neuron 0.5.0 (2026-10-29)
* **Added:** layers for text on the `Graph`: `embed`, `gelu`, `silu`, `layer_norm`, `rms_norm`, causal multi-head `attention` (all with gradients checked numerically); `examples/nano_gpt.jk`, a one-block GPT that trains on a phone in seconds and writes text.
* **Fixed:** none.

## neuron 0.4.0 (2026-10-29)
* **Added:** the training kit: `Graph.linear` / `apply` (a layer), `adamw(lr, decay)`, `clip(max_norm)`, `save(path)` / `load(path)` of the parameters, `Tensor32.gather(idx)` (a mini-batch), `shuffled(n, seed)`, `Sched::cosine` (warm-up and cosine fall). Tested on a two-rings problem; save/load restores the same answers.
* **Fixed:** none.

## neuron 0.3.0 (2026-10-29)
* **Added:** `Tensor32` (float32, up to 4 dimensions, fast threaded matmul: 3.2 GFLOPS at 128, 5.2 at 256) and `Graph` (autograd with a tape: matmul, add with bias, mul, relu, tanh, sigmoid, mse, softmax_ce, backward, sgd). Gradients checked against numeric differences; XOR and a 3-class problem train.
* **Fixed:** none.

## discord 0.2.0 and websocket 0.2.0 (2026-10-29)
* **Added:** `discord`: the live Gateway: `Gw::connect(token, Gw::intents())`, `gw.next(wait_ms)` gives events as they happen (READY, MESSAGE_CREATE with channel/author/bot flag/text, any other event with its JSON, CLOSED, RECONNECT, INVALID_SESSION); the identify and the heartbeats are done by `next`. `websocket`: `ws.recv_wait(ms)` (waits at most ms, kind 0 when nothing came) and `ws.fd()`. Tested against a pretend Gateway.
* **Fixed:** none.

## websocket 0.1.0 (2026-10-29)
* **Added:** `websocket`: a WebSocket client over ws and wss: handshake, masked text and binary frames of any size, ping answered, fragments joined, close frame. Tested against a pretend server.
* **Fixed:** none.

## discord 0.1.0 (2026-10-29)
* **Added:** `discord`: a bot of Discord over REST: `send(channel, text)`, `messages(channel, after, limit)` (oldest first, the id of the newest as `last`, the bot flag); Discord's own words in the errors. The live Gateway (WebSocket) comes later. Tested against a pretend server.
* **Fixed:** none.

## web 0.1.0 and telegram 0.1.0 (2026-10-29)
* **Added:** `web`: an HTTP client for APIs (any method, headers, body, status, redirects, chunked answers, https). `telegram`: a bot of Telegram (me, poll with offsets and long polling, send with the right JSON escapes; errors carry the words of Telegram). Tested against a pretend server. Example `examples/telegram_echo.jk`.
* **Fixed:** none.

## neuron 0.2.0 (2026-10-29)
* **Added:** `Tensor.matmul_fast(o)`: the product of two big tables 5-7 times faster than `matmul` (float32 inside, NEON dot products, 4 threads; 128x128: 2.5 GFLOPS, 256x256: 4.7 GFLOPS on a Kirin 990, `matmul`: 0.5). Small tables use the plain loop. `Dense` (the layers of `Network`) uses it, so networks with big layers train faster.
* **Needs:** the library `simd` now (`jc lib install simd`); `cpu` comes with the compiler. **Fixed:** none.

## gamej 0.2.1 (2026-10-23)
* **Added (permissions):** `Game::allowed("audio")` says whether the program has a permission when `jc` started it (`JC_PERMS`, names with commas; a program started another way has all of them). `game.sound(...)` makes no sound and says so on the error output when the program has no `audio`. The other libraries do not check permissions yet.

## 2026-10-23
* **gpu 0.1.1:** the files of a game are found through `JC_ASSETS` (the new name; `JEC_ASSETS` of the old `.jec` packages is still read). **Fixed:** the checksum of `gpu` in `index.txt` did not match the file, so `jget -li install gpu` would have been refused; it matches now (`tools/check.sh` says OK).
* Documents: `docs/NAME.md` for every library (each function with a short text and a running example), `examples/*.jk`, `tools/gendocs.py`.
* **New in the index since 1.2.0.0 of the compiler:** `native` (call the libraries of the system: dlopen/dlsym from memory), `opengl3` (OpenGL ES 2.0/3.1 with compute shaders), `vulkan` (Vulkan 1.1: device info), `gpu` (the graphics chip through the Jaric app), `gamej` (Jaric Engine), `deflate` (gzip, CRC-32, zip), `neuron` (Tensor, Dense, Network; `.jw` text files). They need `jcmp -dyn` where they call the system (native, opengl3, vulkan).
* Not here: the *program* `neuron` (train and run language models, the assistant `xr`) is a tool of Jcmp-Tools: `jget tool neuron`. This repository has the *library* `<neuron>` for your own J2K programs.
