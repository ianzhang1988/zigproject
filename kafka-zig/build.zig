const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "zig-kafka",
        .root_source_file = b.path("src/main.zig"),
        .target = b.host,
    });
    exe.linkLibC(); // important
    exe.linkSystemLibrary("rdkafka");

    b.installArtifact(exe);
}
