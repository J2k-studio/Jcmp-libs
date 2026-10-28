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
