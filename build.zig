const std = @import("std");
// const glfw = @import("libs/glfw/build.zig");
const raylib = @import("libs/raylib/lib.zig"); //call .Pkg() with the folder raylib-zig is in relative to project build.zig


pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const raylib_use_system = b.option(bool, "system-raylib", "link to preinstalled raylib libraries") orelse false;

    const exe = b.addExecutable("collect-data", "src/collect-data.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    // exe.addPackagePath("glfw", "libs/glfw/src/main.zig");
    // glfw.link(b, exe, .{});
    raylib.link(exe, raylib_use_system);
    raylib.addAsPackage("raylib", exe);
    raylib.math.addAsPackage("raylib-math", exe);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("collect", "Collect Data");
    run_step.dependOn(&run_cmd.step);

    // const exe_tests = b.addTest("src/main.zig");
    // exe_tests.setTarget(target);
    // exe_tests.setBuildMode(mode);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step);
}
