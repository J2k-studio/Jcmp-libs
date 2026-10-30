# `<vulkan>` — Vulkan on the real driver (first step)

Install: `jc lib install vulkan`   Use: `#import <vulkan>`   Build the program with `jcmp -dyn`.

An instance and the first chip: name, version, memory and queues; the rest of Vulkan is built with `native`; build with `jcmp -dyn`.

## About (the header of the library)

```
vulkan 0.1.0 -- the first step of Vulkan from J2K, on the real driver (no app needed).   #import <vulkan>   (needs  jcmp -dyn  and the library native)
Vk vk = Vk::open();                              // makes an instance and looks at the first graphics chip
if !vk.ok { cout << vk.log << "\n"; return; }
cout << vk.device_name << " " << vk.api_text() << " memory " << vk.memory_mb << " MB compute " << vk.has_compute << "\n";
vk.close();
It shows how every Vulkan call is made: a structure built in memory (Vk::struct_* helpers), a function found by name (vk.fn("vkName")),
and Native::call1 .. call8. The next steps (device, queue, buffer, compute pipeline, swapchain) are written the same way.
```

## Example

```jk
#import <stdlib>
#import <vulkan>
int main() {
    Vk vk = Vk::open();
    if !vk.ok { cout << vk.log << "\n"; return 1; }
    cout << vk.device_name << " Vulkan " << vk.api_text() << " memory " << vk.memory_mb << " MB compute " << vk.has_compute << " queues " << vk.queue_families << "\n";
    vk.close();
    return 0;
}
```

Output:

```
Mali-G76 Vulkan 1.1.97 memory 7460 MB compute true queues 1
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Vk`

| call | gives | what it does |
|---|---|---|
| `x.fn(String name)` | `int` | the address of a Vulkan function by name |
| `x.api_text()` | `String` | the Vulkan version as text |
| `Vk::open()` | `Vk` | make an instance and look at the first chip: `device_name`, `api_version`, `memory_mb`, `has_compute`, `queue_families`; `ok` and `log` |
| `x.close()` | `void` | destroy the instance |

## 0.3.0: device, buffers, compute

| call | gives | what it does |
|---|---|---|
| `vk.make_device()` | `bool` | a logical device and one queue of the compute family (`vk.family`) |
| `vk.make_buffer(bytes)` | `VkBuf` | a buffer in memory the CPU and the GPU both see; `b.ok`, `b.ptr` |
| `b.upload(float^ p, n)`, `b.download(float^ p, n)` | | copy numbers in and out |
| `vk.make_compute(int[] spirv, nbuf)` | `Compute` | a compute pipeline from SPIR-V words (entry point `main`; storage buffers 0 .. nbuf-1 of set 0); `k.ok`, `k.error` |
| `k.bind(i, b)` | | buffer `b` is the storage buffer `i` of the shader |
| `k.run(gx, gy, gz)` | `bool` | dispatch and wait; false and `k.error` when a call fails |
| `k.destroy()`, `b.destroy()`, `vk.close()` | | free in this order: pipeline, buffers, then the device |
| `VkShaders::vector_add()` | `int[]` | a ready SPIR-V shader: `c[i] = a[i] + b[i]`, local size 64 |
| `Vk::result_text(rc)` | `String` | the name of a `VkResult` |

A struct that has a method called `free` is freed when a function that took it by value ends; that is why `VkBuf` and `Compute` use `destroy`.
