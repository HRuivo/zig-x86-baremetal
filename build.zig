const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel = buildKernel(b);

    const run_step = b.step("run", "Run in Qemu");
    const run_qemu = b.addSystemCommand(&(.{
        "qemu-system-x86_64",
        "-kernel",
        b.pathJoin(&.{ "zig-out/bin", kernel }),
    }));
    run_qemu.step.dependOn(b.default_step);
    run_step.dependOn(&run_qemu.step);
}

fn buildKernel(b: *std.Build) []const u8 {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_model = std.Target.Query.CpuModel{ .explicit = &std.Target.x86.cpu.i386 },
    });

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = b.path("src/kernel.zig"),
        .target = target,
        .optimize = b.standardOptimizeOption(.{}),
        .strip = true,
    });
    kernel.setLinkerScript(b.path("src/kernel.ld"));

    const copy_kernel_object = b.addInstallBinFile(kernel.getEmittedBin(), "kernel.o");

    b.default_step.dependOn(&copy_kernel_object.step);
    copy_kernel_object.step.dependOn(&kernel.step);

    return copy_kernel_object.dest_rel_path;
}
