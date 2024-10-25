// --- Day 4: Security Through Obscurity ---
// Finally, you come across an information kiosk with a list of rooms. Of course, the list is encrypted and full of decoy data, but the instructions to decode the list are barely hidden nearby. Better remove the decoy data first.
//
// Each room consists of an encrypted name (lowercase letters separated by dashes) followed by a dash, a sector ID, and a checksum in square brackets.
//
// A room is real (not a decoy) if the checksum is the five most common letters in the encrypted name, in order, with ties broken by alphabetization. For example:
//
// aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common letters are a (5), b (3), and then a tie between x, y, and z, which are listed alphabetically.
// a-b-c-d-e-f-g-h-987[abcde] is a real room because although the letters are all tied (1 of each), the first five are listed alphabetically.
// not-a-real-room-404[oarel] is a real room.
// totally-real-room-200[decoy] is not.
// Of the real rooms from the list above, the sum of their sector IDs is 1514.
//
// What is the sum of the sector IDs of the real rooms?
//
const std = @import("std");
const String = @import("string").String;
const Allocator = std.mem.Allocator;

const Room = struct {
    name: std.ArrayList(String),
    sector: u32,
    checksum: String,
};

fn parse(in: []const u8, alloc: Allocator) !Room {
    var line = String.init(alloc);
    defer line.deinit();
    try line.setStr(in);

    const parts = try line.splitAllToStrings("-");
    defer std.heap.page_allocator.free(parts);

    // std.debug.print("str: {s}\n", .{line.str()});

    var room = Room{ .name = std.ArrayList(String).init(alloc), .sector = 0, .checksum = String.init(alloc) };

    for (parts[0 .. parts.len - 1]) |s| {
        try room.name.append(s);
        std.debug.print("part: {s}\n", .{s.str()});
    }

    var tmp = parts[parts.len - 1];
    defer tmp.deinit();

    var sector = try tmp.substr(0, 3);
    defer sector.deinit();
    var checksumStr = try tmp.substr(4, 9);
    defer checksumStr.deinit();
    std.debug.print("sector: {s}\n", .{sector.str()});
    std.debug.print("checksum: {s}\n", .{checksumStr.str()});

    room.sector = try std.fmt.parseInt(u32, sector.str(), 10);
    try room.checksum.setStr(checksumStr.str());

    return room;
}

fn checksum(name: *const std.ArrayList(String), outStr: *String) !void {
    var charCount = [_]u32{0} ** 26;

    for (name.*.items) |s| {
        for (s.str()) |c| {
            charCount[c - 'a'] += 1;
        }
    }
    std.debug.print("char counter: {any}\n", .{charCount});

    var checksumSlice = [_]u8{0} ** 5;

    for (checksumSlice, 0..) |_, i| {
        var max: u32 = 0;
        var pos: u8 = charCount.len;
        for (charCount, 0..) |c, ii| {
            if (c > max) {
                max = c;
                pos = @intCast(ii);
                // std.debug.print("pos: {}\n", .{pos});
            }
        }
        charCount[pos] = 0;

        std.debug.assert(pos != charCount.len);

        checksumSlice[i] = pos + 'a';
    }

    std.debug.print("calcu checksum: {s}\n", .{checksumSlice});

    try outStr.*.setStr(&checksumSlice);
}

pub fn main() !void {
    std.debug.print("day04!\n", .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n

    var lines = std.mem.split(u8, content, "\n");

    var i: u32 = 0;
    var count: i32 = 0;
    while (lines.next()) |l| : (i += 1) {
        std.debug.print("line: {s}\n", .{l});
        const room = try parse(l, alloc);

        var checksumStr = String.init(alloc);
        defer checksumStr.deinit();

        try checksum(&room.name, &checksumStr);

        if (room.checksum.cmp(checksumStr.str())) {
            count += @intCast(room.sector);
        }
    }
    std.debug.print("count: {}\n", .{count});

    // var str = String.init(alloc);
    // defer str.deinit();
    // try str.concat("hi");
    // std.debug.print("str: {s}\n", .{str.str()});
}
