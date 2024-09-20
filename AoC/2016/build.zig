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
}
