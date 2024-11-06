// --- Day 7: Internet Protocol Version 7 ---
// While snooping around the local network of EBHQ, you compile a list of IP addresses (they're IPv7, of course; IPv6 is much too limited). You'd like to figure out which IPs support TLS (transport-layer snooping).
//
// An IP supports TLS if it has an Autonomous Bridge Bypass Annotation, or ABBA. An ABBA is any four-character sequence which consists of a pair of two different characters followed by the reverse of that pair, such as xyyx or abba. However, the IP also must not have an ABBA within any hypernet sequences, which are contained by square brackets.
//
// For example:
//
// abba[mnop]qrst supports TLS (abba outside square brackets).
// abcd[bddb]xyyx does not support TLS (bddb is within square brackets, even though xyyx is outside square brackets).
// aaaa[qwer]tyui does not support TLS (aaaa is invalid; the interior characters must be different).
// ioxxoj[asdfgh]zxcvbn supports TLS (oxxo is outside square brackets, even though it's within a larger string).
// How many IPs in your puzzle input support TLS?
//
// --- Part Two ---
// You would also like to know which IPs support SSL (super-secret listening).
//
// An IP supports SSL if it has an Area-Broadcast Accessor, or ABA, anywhere in the supernet sequences (outside any square bracketed sections), and a corresponding Byte Allocation Block, or BAB, anywhere in the hypernet sequences. An ABA is any three-character sequence which consists of the same character twice with a different character between them, such as xyx or aba. A corresponding BAB is the same characters but in reversed positions: yxy and bab, respectively.
//
// For example:
//
// aba[bab]xyz supports SSL (aba outside square brackets with corresponding bab within square brackets).
// xyx[xyx]xyx does not support SSL (xyx, but no corresponding yxy).
// aaa[kek]eke supports SSL (eke in supernet with corresponding kek in hypernet; the aaa sequence is not related, because the interior character must be different).
// zazbz[bzb]cdb supports SSL (zaz has no corresponding aza, but zbz has a corresponding bzb, even though zaz and zbz overlap).
// How many IPs in your puzzle input support SSL?

const std = @import("std");

fn isABBA(in: []const u8) bool {
    var pos: usize = 0;
    const ret = while (pos + 3 < in.len) : (pos += 1) {
        const A = in[pos];
        const B = in[pos + 1];
        const B_ = in[pos + 2];
        const A_ = in[pos + 3];

        if (A != B and A == A_ and B == B_) {
            break true;
        }
    } else false;

    return ret;
}

fn findABA(alloc: std.mem.Allocator, in: []const u8) !std.ArrayList([]u8) {
    var ABAarray = std.ArrayList([]u8).init(alloc);

    var pos: usize = 0;
    while (pos + 2 < in.len) : (pos += 1) {
        const A = in[pos];
        const B = in[pos + 1];
        const A_ = in[pos + 2];

        if (A != B and A == A_) {
            const abaSubStr = try alloc.alloc(u8, 3);
            std.mem.copyForwards(u8, abaSubStr, in[pos .. pos + 3]);
            try ABAarray.append(abaSubStr);
        }
    }

    return ABAarray;
}

fn parse(in: []const u8, alloc: std.mem.Allocator) ![][]u8 {
    // std.debug.print("line: {s}\n", .{in});
    var bracketsNum: u32 = 0;
    for (in) |c| {
        if (c == '[') {
            bracketsNum += 1;
        }
    }

    var stringList = try alloc.alloc([]u8, bracketsNum * 2 + 1);

    var start: usize = 0;
    var pos = start;
    var listPos: usize = 0;

    for (in) |c| {
        if (c == '[' or c == ']') {
            const len = pos - start;
            const data = try alloc.alloc(u8, len);
            std.mem.copyForwards(u8, data, in[start..pos]);
            stringList[listPos] = data;

            start = pos + 1;
            listPos += 1;
        }
        pos += 1;
    }
    const len = pos - start;
    const data = try alloc.alloc(u8, len);
    std.mem.copyForwards(u8, data, in[start..pos]);
    stringList[listPos] = data;

    return stringList;
}

pub fn main() !void {
    std.debug.print("day07!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const alloc = arena.allocator();

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day07", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024 * 100);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n
    var lines = std.mem.split(u8, content, "\n");

    // const testInput =
    //     \\abba[mnop]qrst
    //     \\abcd[bddb]xyyx
    //     \\aaaa[qwer]tyui
    //     \\ioxxoj[asdfgh]zxcvbn
    // ;
    // var lines = std.mem.splitSequence(u8, testInput, "\n");
    //
    // part2
    // const testInput =
    //     \\aba[bab]xyz
    //     \\xyx[xyx]xyx
    //     \\aaa[kek]eke
    //     \\zazbz[bzb]cdb
    // ;
    // var lines = std.mem.splitSequence(u8, testInput, "\n");

    var i: u32 = 0;
    while (lines.next()) |l| : (i += 1) {
        if (i > 5) {
            break;
        }
        std.debug.print("line: {s}\n", .{l});
        const output = try parse(l, alloc);
        for (output, 0..) |s, idx| {
            std.debug.print("word{}: {s}\n", .{ idx, s });
        }
    }

    const testStrs = [_][]const u8{ "ioxxoj", "ioxyoj", "abba", "aaaa", "abbai", "iabba", "iabba", "abab" };
    for (testStrs) |s| {
        std.debug.print("test {s}: {any}\n", .{ s, isABBA(s) });
    }

    lines.reset();
    var counter: u32 = 0;
    while (lines.next()) |l| {
        var arenaTmp = std.heap.ArenaAllocator.init(gpa.allocator());
        defer arenaTmp.deinit();
        const allocTmp = arenaTmp.allocator();

        const output = try parse(l, allocTmp);

        var validTSL1 = false;
        var validTSL2 = true;
        // if ((isABBA(output[0]) or isABBA(output[2])) and !isABBA(output[1])) {
        //     validTSL = true;
        // }
        for (output, 0..) |s, idx| {
            if (@mod(idx, 2) == 0) {
                validTSL1 = validTSL1 or isABBA(s);
            } else {
                validTSL2 = validTSL2 and !isABBA(s);
            }
        }

        // std.debug.print("line: {s}\n", .{l});
        if (validTSL1 and validTSL2) {
            counter += 1;
            // std.debug.print("valid\n", .{});
        }
    }

    std.debug.print("counter: {}\n", .{counter});

    // part2
    lines.reset();
    counter = 0;
    while (lines.next()) |l| {
        var arenaTmp = std.heap.ArenaAllocator.init(gpa.allocator());
        defer arenaTmp.deinit();
        const allocTmp = arenaTmp.allocator();

        const output = try parse(l, allocTmp);

        var superArray = std.ArrayList([]u8).init(allocTmp);
        var hyperArray = std.ArrayList([]u8).init(allocTmp);

        for (output, 0..) |s, idx| {
            const ABAarray = try findABA(arenaTmp.allocator(), s);
            if (@mod(idx, 2) == 0) {
                try superArray.appendSlice(ABAarray.items);
            } else {
                try hyperArray.appendSlice(ABAarray.items);
            }
        }

        outer: for (superArray.items) |aba| {
            const bab = .{ aba[1], aba[0], aba[1] };

            for (hyperArray.items) |babItem| {
                if (std.mem.eql(u8, babItem, &bab)) {
                    counter += 1;

                    break :outer;
                    // std.debug.print("part2 support: {s}\n", .{l});
                }
            }
        }
    }

    std.debug.print("part2 counter: {}\n", .{counter});
}
