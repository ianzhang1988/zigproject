const std = @import("std");
const Regex = @import("regex").Regex;

pub fn main() !void {
    std.debug.print("day10!\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const alloc = arena.allocator();

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day10", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024 * 100);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n
    var lines = std.mem.split(u8, content, "\n");

    var c: u32 = 0;
    while (lines.next()) |l| : (c += 1) {
        std.debug.print("line: {s}\n", .{l});
        if (c >= 5) {
            break;
        }
    }
}
