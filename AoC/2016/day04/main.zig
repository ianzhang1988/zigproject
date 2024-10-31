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
//--- Part Two ---
// With all the decoy data out of the way, it's time to decrypt this list and get moving.
//
// The room names are encrypted by a state-of-the-art shift cipher, which is nearly unbreakable without the right software. However, the information kiosk designers at Easter Bunny HQ were not expecting to deal with a master cryptographer like yourself.
//
// To decrypt a room name, rotate each letter forward through the alphabet a number of times equal to the room's sector ID. A becomes B, B becomes C, Z becomes A, and so on. Dashes become spaces.
//
// For example, the real name for qzmt-zixmtkozy-ivhz-343 is very encrypted name.
//
// What is the sector ID of the room where North Pole objects are stored?

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
        // std.debug.print("part: {s}\n", .{s.str()});
    }

    var tmp = parts[parts.len - 1];
    defer tmp.deinit();

    var sector = try tmp.substr(0, 3);
    defer sector.deinit();
    var checksumStr = try tmp.substr(4, 9);
    defer checksumStr.deinit();
    // std.debug.print("sector: {s}\n", .{sector.str()});
    // std.debug.print("checksum: {s}\n", .{checksumStr.str()});

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
    // std.debug.print("char counter: {any}\n", .{charCount});

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

    // std.debug.print("calcu checksum: {s}\n", .{checksumSlice});

    try outStr.*.setStr(&checksumSlice);
}

fn decrypt(alloc: std.mem.Allocator, in: []const u8, forwardNum: i32) ![]u8 {
    var tmpStr = try alloc.alloc(u8, in.len);

    std.mem.copyForwards(u8, tmpStr, in);

    for (tmpStr, 0..) |c, i| {
        // std.debug.print("cb:{c}\n", .{c});
        tmpStr[i] = @intCast(@mod(c - 'a' + forwardNum, 26) + 'a');
        // std.debug.print("ca:{c}\n", .{tmpStr[i]});
    }

    return tmpStr;
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

    const decryptedName = "northpole object storage ";
    // var decryptedName =  String.init(alloc);
    // defer decryptedName.deinit();
    // decryptedName.setStr("North Pole objects ");

    while (lines.next()) |l| : (i += 1) {
        // std.debug.print("line: {s}\n", .{l});
        const room = try parse(l, alloc);

        var checksumStr = String.init(alloc);
        defer checksumStr.deinit();

        try checksum(&room.name, &checksumStr);

        if (room.checksum.cmp(checksumStr.str())) {
            count += @intCast(room.sector);
        }

        var tmpName = String.init(alloc);
        defer tmpName.deinit();

        for (room.name.items) |p| {
            const decrypted = try decrypt(alloc, p.str(), @intCast(room.sector));
            defer alloc.free(decrypted);

            try tmpName.concat(decrypted);
            try tmpName.concat(" ");
        }

        // std.debug.print("decrypted name: {s}, id:{}\n", .{ tmpName.str(), room.sector });
        if (tmpName.cmp(decryptedName)) {
            std.debug.print("name: {s}, id:{}\n", .{ tmpName.str(), room.sector });
        }
    }
    std.debug.print("count: {}\n", .{count});

    // var str = String.init(alloc);
    // defer str.deinit();
    // try str.concat("hi");
    // std.debug.print("str: {s}\n", .{str.str()});
    //
    const encryptedName = [_][]const u8{ "qzmt", "zixmtkozy", "ivhz" };
    const num = 343;
    for (encryptedName) |str| {
        std.debug.print("orig: {s}\n", .{str});
        const decrypted = try decrypt(alloc, str, num);
        defer alloc.free(decrypted);
        std.debug.print("de: {s}\n", .{decrypted});
    }
}
