# zig-x86-baremetal
Barebones x86 kernel written in [Zig](http://ziglang.org).

## Build and run
To build the kernel:
```
zig build-exe src/freestanding.zig -target x86-freestanding -T linker.ld
```

You can run the kernel with Qemu:
```
qemu-system-x86_64 -kernel kernel
```