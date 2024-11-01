// const std = @import("std");

// pub fn build(b: *std.build.Builder) void {
//     const mode = b.standardReleaseOptions();

//     // 下载并添加 GitHub 依赖库
//     //const repo_fetch = std.build.git.fetch(b, "https://github.com/user/repo", "main", "deps/repo");

//     // 第一个程序
//     const day1 = b.addExecutable("day1", "day01/main.zig");
//     day1.setBuildMode(mode);
//     // exe1.addPackagePath("repo", repo_fetch);  // 使用下载的库路径
//     day1.install();

//     // 自定义运行 app1 的步骤
//     const run_app1 = b.addRunExecutable(day1, "day01");  // 指定名称为 run-app1
//     run_app1.step.dependOn(b.getInstallStep());

//     // // 第二个程序
//     // const exe2 = b.addExecutable("app2", "src/app2.zig");
//     // exe2.setBuildMode(mode);
//     // exe2.install();

//     // // 自定义运行 app2 的步骤
//     // const run_app2 = b.addRunExecutable(exe2, "run-app2");  // 指定名称为 run-app2
//     // run_app2.step.dependOn(b.getInstallStep());
// }

const std = @import("std");
const Git = @import("std").fs.git; // 导入 git 模块

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "day01",
        .root_source_file = b.path("day01/main.zig"),
        .target = b.host,
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("day01", "Run the application");
    run_step.dependOn(&run_exe.step);

    // day2
    const day02_exe = b.addExecutable(.{
        .name = "day02",
        .root_source_file = b.path("day02/main.zig"),
        .target = b.host,
    });

    b.installArtifact(day02_exe);

    const day02_run = b.addRunArtifact(day02_exe);

    const day02_run_step = b.step("day02", "Run the application");
    day02_run_step.dependOn(&day02_run.step);

    // day03
    const day03_exe = b.addExecutable(.{
        .name = "day03",
        .root_source_file = b.path("day03/main.zig"),
        .target = b.host,
    });

    b.installArtifact(day03_exe);

    const day03_run = b.addRunArtifact(day03_exe);

    const day03_run_step = b.step("day03", "Run the application");
    day03_run_step.dependOn(&day03_run.step);

    // day04
    const day04_exe = b.addExecutable(.{
        .name = "day04",
        .root_source_file = b.path("day04/main.zig"),
        .target = b.host,
    });

    const string = b.dependency("string", .{
        .target = b.host,
    });
    day04_exe.root_module.addImport("string", string.module("string"));

    b.installArtifact(day04_exe);

    const day04_run = b.addRunArtifact(day04_exe);

    const day04_run_step = b.step("day04", "Run the application");
    day04_run_step.dependOn(&day04_run.step);

    // day05
    const day05_exe = b.addExecutable(.{
        .name = "day05",
        .root_source_file = b.path("day05/main.zig"),
        .target = b.host,
    });

    b.installArtifact(day05_exe);

    const day05_run = b.addRunArtifact(day05_exe);

    const day05_run_step = b.step("day05", "Run the application");
    day05_run_step.dependOn(&day05_run.step);
}
