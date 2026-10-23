# Jcmp-libs changelog (what changed in the libraries, newest first)

## gamej 0.2.1 (2026-10-23)
* **Added (permissions):** `Game::allowed("audio")` says whether the program has a permission when `jc` started it (`JC_PERMS`, names with commas; a program started another way has all of them). `game.sound(...)` makes no sound and says so on the error output when the program has no `audio`. The other libraries do not check permissions yet.

## 2026-10-23
* **gpu 0.1.1:** the files of a game are found through `JC_ASSETS` (the new name; `JEC_ASSETS` of the old `.jec` packages is still read). **Fixed:** the checksum of `gpu` in `index.txt` did not match the file, so `jget -li install gpu` would have been refused; it matches now (`tools/check.sh` says OK).
* Documents: `docs/NAME.md` for every library (each function with a short text and a running example), `examples/*.jk`, `tools/gendocs.py`.
* **New in the index since 1.2.0.0 of the compiler:** `native` (call the libraries of the system: dlopen/dlsym from memory), `opengl3` (OpenGL ES 2.0/3.1 with compute shaders), `vulkan` (Vulkan 1.1: device info), `gpu` (the graphics chip through the Jaric app), `gamej` (Jaric Engine), `deflate` (gzip, CRC-32, zip), `neuron` (Tensor, Dense, Network; `.jw` text files). They need `jcmp -dyn` where they call the system (native, opengl3, vulkan).
* Not here: the *program* `neuron` (train and run language models, the assistant `xr`) is a tool of Jcmp-Tools: `jget tool neuron`. This repository has the *library* `<neuron>` for your own J2K programs.
