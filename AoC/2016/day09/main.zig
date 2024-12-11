// --- Day 9: Explosives in Cyberspace ---
// Wandering around a secure area, you come across a datalink port to a new part of the network. After briefly scanning it for interesting files, you find one file in particular that catches your attention. It's compressed with an experimental format, but fortunately, the documentation for the format is nearby.
//
// The format compresses a sequence of characters. Whitespace is ignored. To indicate that some sequence should be repeated, a marker is added to the file, like (10x2). To decompress this marker, take the subsequent 10 characters and repeat them 2 times. Then, continue reading the file after the repeated data. The marker itself is not included in the decompressed output.
//
// If parentheses or other characters appear within the data referenced by a marker, that's okay - treat it like normal data, not a marker, and then resume looking for markers after the decompressed section.
//
// For example:
//
// ADVENT contains no markers and decompresses to itself with no changes, resulting in a decompressed length of 6.
// A(1x5)BC repeats only the B a total of 5 times, becoming ABBBBBC for a decompressed length of 7.
// (3x3)XYZ becomes XYZXYZXYZ for a decompressed length of 9.
// A(2x2)BCD(2x2)EFG doubles the BC and EF, becoming ABCBCDEFEFG for a decompressed length of 11.
// (6x1)(1x3)A simply becomes (1x3)A - the (1x3) looks like a marker, but because it's within a data section of another marker, it is not treated any differently from the A that comes after it. It has a decompressed length of 6.
// X(8x2)(3x3)ABCY becomes X(3x3)ABC(3x3)ABCY (for a decompressed length of 18), because the decompressed data from the (8x2) marker (the (3x3)ABC) is skipped and not processed further.
// What is the decompressed length of the file (your puzzle input)? Don't count whitespace.

const std = @import("std");
// const String = @import("string").String;
//
const myError = error{
    MalFormat,
};

fn decode(in: []const u8, out: *std.ArrayList(u8)) !void {
    // try out.*.appendSlice(in[0..1]);

    var poslp: usize = 0;
    var posrp: usize = 0;

    var processedPos: usize = 0;

    while (processedPos < in.len) {
        if (in[processedPos] == '(') {
            poslp = processedPos;
            posrp = processedPos + 1;

            while (in[posrp] != ')' and posrp < in.len) {
                posrp += 1;
            }

            if (posrp == in.len) {
                return myError.MalFormat;
            }

            const ins = in[poslp + 1 .. posrp];
            std.debug.print("ins: {s}\n", .{ins});
            var parts = std.mem.split(u8, ins, "x");

            const range = parts.next().?;
            std.debug.print("range: {s}\n", .{range});
            const repeatRange = try std.fmt.parseInt(usize, range, 10);

            const times = parts.next().?;
            std.debug.print("times: {s}\n", .{times});
            const repeatTimes = try std.fmt.parseInt(usize, times, 10);

            for (0..repeatTimes) |_| {
                try out.*.appendSlice(in[posrp + 1 .. posrp + 1 + repeatRange]);
            }

            processedPos = posrp + 1 + repeatRange;
        } else {
            try out.*.append(in[processedPos]);
            processedPos += 1;
        }
    }
}

fn mytest(alloc: std.mem.Allocator) !void {
    const dataList = [_][]const u8{ "ADVENT", "A(1x5)BC", "(3x3)XYZ", "A(2x2)BCD(2x2)EFG", "(6x1)(1x3)A", "X(8x2)(3x3)ABCY" };

    for (dataList) |i| {
        std.debug.print("code: {s}\n", .{i});
        var decompressed = std.ArrayList(u8).init(alloc);

        try decode(i, &decompressed);

        std.debug.print("decode: {s}\n", .{decompressed.items});
    }
}

pub fn main() !void {
    std.debug.print("day09!\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const alloc = arena.allocator();

    try mytest(alloc);

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day09", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024 * 100);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n

    std.debug.print("last string: {s}\n", .{content[content.len - 10 .. content.len]});

    var decompressed = std.ArrayList(u8).init(alloc);

    try decode(content, &decompressed);

    // std.debug.print("decompressed string: {s}\n", .{decompressed.items});
    std.debug.print("decompressed string len: {}\n", .{decompressed.items.len});
}
