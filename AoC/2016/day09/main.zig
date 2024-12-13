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
// What is the decompressed length of the file (your puzzle input)? Don't count whitespasce.
//
// --- Part Two ---
// Apparently, the file actually uses version two of the format.
//
// In version two, the only difference is that markers within decompressed data are decompressed. This, the documentation explains, provides much more substantial compression capabilities, allowing many-gigabyte files to be stored in only a few kilobytes.
//
// For example:
//
// (3x3)XYZ still becomes XYZXYZXYZ, as the decompressed section contains no markers.
// X(8x2)(3x3)ABCY becomes XABCABCABCABCABCABCY, because the decompressed data from the (8x2) marker is then further decompressed, thus triggering the (3x3) marker twice for a total of six ABC sequences.
// (27x12)(20x12)(13x14)(7x10)(1x12)A decompresses into a string of A repeated 241920 times.
// (25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN becomes 445 characters long.
// Unfortunately, the computer you brought probably doesn't have enough memory to actually decompress the file; you'll have to come up with another way to get its decompressed length.
//
// What is the decompressed length of the file using this improved format?

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

const Frame = struct { plain: bool, content: []const u8, factor: u64 };

fn decode2(input: []const u8) !u64 {
    var sum: u64 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const gpa_alloc = gpa.allocator();

    var stack = std.ArrayList(Frame).init(gpa_alloc);
    defer stack.deinit();
    try stack.append(Frame{ .plain = false, .content = input, .factor = 1 });

    while (stack.items.len > 0) {
        const frame = stack.pop();
        // std.debug.print("frame: {?}\n", .{frame});
        std.debug.print("frame: plain:{?}, content:{s}, factor:{}\n", .{ frame.plain, frame.content, frame.factor });
        const in = frame.content;

        if (frame.plain) {
            sum += frame.factor * frame.content.len;
            continue;
        }

        var poslp: usize = 0;
        var posrp: usize = 0;

        var processedPos: usize = 0;
        var nextParsePos: usize = 0;

        // var newFrame = Frame{ .plain = false, .content = []const u8{}, .factor = 1 };

        while (processedPos < in.len) {
            if (in[processedPos] == '(') {

                // extract plain txt
                if (nextParsePos < processedPos) {
                    const newFrame = Frame{ .plain = true, .content = in[nextParsePos..processedPos], .factor = frame.factor };
                    try stack.append(newFrame);
                }

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

                {
                    var newFrame = Frame{ .plain = false, .content = in[posrp + 1 .. posrp + 1 + repeatRange], .factor = frame.factor * repeatTimes };
                    if (std.mem.indexOf(u8, newFrame.content, "(") == null) {
                        newFrame.plain = true;
                    }

                    try stack.append(newFrame);
                }

                processedPos = posrp + 1 + repeatRange;
                nextParsePos = processedPos;
            } else {
                processedPos += 1;
            }
        }

        // extract surfix
        if (nextParsePos < in.len) {
            const newFrame = Frame{ .plain = true, .content = in[nextParsePos..in.len], .factor = frame.factor };
            try stack.append(newFrame);
        }
    }

    return sum;
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

fn mytest2() !void {
    // (3x3)XYZ still becomes XYZXYZXYZ, as the decompressed section contains no markers.
    // X(8x2)(3x3)ABCY becomes XABCABCABCABCABCABCY, because the decompressed data from the (8x2) marker is then further decompressed, thus triggering the (3x3) marker twice for a total of six ABC sequences.
    // (27x12)(20x12)(13x14)(7x10)(1x12)A decompresses into a string of A repeated 241920 times.
    // (25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN becomes 445 characters long.
    const dataList = [_][]const u8{ "(3x3)XYZ", "X(8x2)(3x3)ABCY", "(27x12)(20x12)(13x14)(7x10)(1x12)A", "(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN" };
    const numList = [_]u32{ 9, 20, 241920, 445 };

    for (dataList, 0..) |i, idx| {
        std.debug.print("code: {s}\n", .{i});

        const num = try decode2(i);

        std.debug.print("decode num: {}, expect {}\n", .{ num, numList[idx] });
    }
}

pub fn main() !void {
    std.debug.print("day09!\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const alloc = arena.allocator();

    // try mytest(alloc);

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day09", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024 * 100);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n

    std.debug.print("last string: {s}\n", .{content[content.len - 10 .. content.len]});

    // var decompressed = std.ArrayList(u8).init(alloc);

    // try decode(content, &decompressed);
    //
    // // std.debug.print("decompressed string: {s}\n", .{decompressed.items});
    // std.debug.print("decompressed string len: {}\n", .{decompressed.items.len});

    try mytest2();

    const num = try decode2(content);
    std.debug.print("decompressed string len: {}\n", .{num});
}
