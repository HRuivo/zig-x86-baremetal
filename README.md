# zig-x86-baremetal
Barebones x86 kernel written in [Zig](http://ziglang.org) with a custom build system to run in Qemu.

Heavily based on the amazing Austin Hanson article. [Bare Metal Zig](https://austinhanson.com/bare-metal-ziglang/)

## Zig Version
```
zig 0.14.0
```

## Build and run
To build the kernel:
```
zig build-exe src/freestanding.zig -target x86-freestanding -T linker.ld
```

You can run the kernel with Qemu:
```
qemu-system-x86_64 -kernel kernel
```