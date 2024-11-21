// --- Day 8: Two-Factor Authentication ---
// You come across a door implementing what you can only assume is an implementation of two-factor authentication after a long game of requirements telephone.
//
// To get past the door, you first swipe a keycard (no problem; there was one on a nearby desk). Then, it displays a code on a little screen, and you type that code on a keypad. Then, presumably, the door unlocks.
//
// Unfortunately, the screen has been smashed. After a few minutes, you've taken everything apart and figured out how it works. Now you just have to work out what the screen would have displayed.
//
// The magnetic strip on the card you swiped encodes a series of instructions for the screen; these instructions are your puzzle input. The screen is 50 pixels wide and 6 pixels tall, all of which start off, and is capable of three somewhat peculiar operations:
//
// rect AxB turns on all of the pixels in a rectangle at the top-left of the screen which is A wide and B tall.
// rotate row y=A by B shifts all of the pixels in row A (0 is the top row) right by B pixels. Pixels that would fall off the right end appear at the left end of the row.
// rotate column x=A by B shifts all of the pixels in column A (0 is the left column) down by B pixels. Pixels that would fall off the bottom appear at the top of the column.
// For example, here is a simple sequence on a smaller screen:
//
// rect 3x2 creates a small rectangle in the top-left corner:
//
// ###....
// ###....
// .......
// rotate column x=1 by 1 rotates the second column down by one pixel:
//
// #.#....
// ###....
// .#.....
// rotate row y=0 by 4 rotates the top row right by four pixels:
//
// ....#.#
// ###....
// .#.....
// rotate column x=1 by 1 again rotates the second column down by one pixel, causing the bottom pixel to wrap back to the top:
//
// .#..#.#
// #.#....
// .#.....
// As you can see, this display technology is extremely powerful, and will soon dominate the tiny-code-displaying-screen market. That's what the advertisement on the back of the display tries to convince you, anyway.
//
// There seems to be an intermediate check of the voltage used by the display: after you swipe your card, if the screen did work, how many pixels should be lit?
//
// ------ part two
//You notice that the screen is only capable of displaying capital letters; in the font it uses, each letter is 5 pixels wide and 6 tall.
//
// After you swipe your card, what code is the screen trying to display?

const std = @import("std");
const Regex = @import("regex").Regex;

fn extract(alloc: std.mem.Allocator, comptime regex: []const u8, in: []const u8, T: anytype, comptime num: usize, output: *[num]T) !bool {
    // std.debug.print("regex: {s}\n", .{regex});
    // std.debug.print("in: {s}\n", .{in});
    var re = try Regex.compile(alloc, regex);
    const capOp = try re.captures(in);

    if (capOp == null) {
        return false;
    }

    // var params: [2]u32 = .{ 0, 0 };

    const cap = capOp.?;

    for (0..2) |i| {
        const numOp = cap.sliceAt(i + 1);
        if (numOp == null) {
            continue;
        }
        // std.debug.print("column num: {s}\n", .{numOp.?});
        output.*[i] = try std.fmt.parseInt(u32, numOp.?, 10);
    }

    return true;
}

const Rotate = union(enum) {
    Row: [2]u32,
    Column: [2]u32,

    pub fn parse(alloc: std.mem.Allocator, in: []const u8) !?Rotate {
        {
            var params: [2]u32 = .{ 0, 0 };
            const ok = try extract(alloc, "rotate column x=(\\d+) by (\\d+)", in, u32, 2, &params);
            if (ok) {
                return Rotate{ .Column = params };
            }
        }

        {
            var params: [2]u32 = .{ 0, 0 };
            const ok = try extract(alloc, "rotate row y=(\\d+) by (\\d+)", in, u32, 2, &params);
            if (ok) {
                return Rotate{ .Row = params };
            }
        }

        return null;
    }
};

const Instruction = union(enum) {
    Rect: [2]u32,
    Rotate: Rotate,

    pub fn parse(alloc: std.mem.Allocator, in: []const u8) !?Instruction {
        {
            var params: [2]u32 = .{ 0, 0 };
            const ok = try extract(alloc, "rect (\\d+)x(\\d+)", in, u32, 2, &params);
            if (ok) {
                return Instruction{ .Rect = params };
            }
        }

        if (try Rotate.parse(alloc, in)) |v| {
            return Instruction{ .Rotate = v };
        }

        return null;
    }
};

fn tagUnion() void {
    const instructions = [_]Instruction{
        Instruction{ .Rect = .{ 1, 2 } },
        Instruction{ .Rotate = Rotate{ .Row = .{ 3, 4 } } },
        Instruction{ .Rotate = Rotate{ .Column = .{ 3, 4 } } },
    };
    for (instructions) |i| {
        std.debug.print("cap: {?}\n", .{i});
        switch (i) {
            .Rect => |r| std.debug.print("cap: {any}\n", .{r}),
            .Rotate => |r| switch (r) {
                .Row => |v| std.debug.print("cap: {any}\n", .{v}),
                .Column => |v| std.debug.print("cap: {any}\n", .{v}),
            },
        }
    }
}

fn regexTest(alloc: std.mem.Allocator) !void {
    var re = try Regex.compile(alloc, "rect (\\d+)x(\\d+)");
    defer re.deinit();

    const capOp = try re.captures("rect 3x2");

    std.debug.print("cap? {}\n", .{capOp != null});

    if (capOp == null) {
        return;
    }

    const cap = capOp.?;

    for (0..cap.len()) |i| {
        const numOp = cap.sliceAt(i);
        if (numOp == null) {
            continue;
        }
        std.debug.print("cap: {s}\n", .{numOp.?});
    }
}

fn StaticGrid(comptime T: anytype, default: T, comptime wide: u32, comptime height: u32) type {
    return struct {
        grid: [height][wide]T,
        width: u32,
        height: u32,

        const Self = @This();

        fn init() Self {
            return Self{ .grid = .{.{default} ** wide} ** height, .width = wide, .height = height };
        }

        fn clear(self: *Self) void {
            for (self.grid, 0..) |row, y| {
                for (row, 0..) |_, x| {
                    self.grid[y][x] = default;
                }
            }
        }

        fn putRect(self: *Self, rectW: u32, rectH: u32) void {
            for (0..rectH) |y| {
                for (0..rectW) |x| {
                    self.grid[y][x] = true;
                }
            }
        }

        fn rotateRow(self: *Self, y: u32, num: u32) void {
            var tempRow: [wide]T = .{default} ** wide;
            for (self.grid[y], 0..) |value, i| {
                tempRow[@mod((i + num), wide)] = value;
            }
            self.grid[y] = tempRow;
        }

        fn rotateColumn(self: *Self, x: u32, num: u32) void {
            var tempCol: [height]T = .{default} ** height;
            for (0..height) |y| {
                const value = self.grid[y][x];
                tempCol[@mod((y + num), height)] = value;
            }

            for (0..height) |y| {
                self.grid[y][x] = tempCol[y];
            }
        }

        fn show(self: *Self) void {
            for (self.grid, 0..) |row, y| {
                for (row, 0..) |_, x| {
                    const value = self.grid[y][x];
                    var char: u8 = 0;
                    if (value) {
                        char = '#';
                    } else {
                        char = '.';
                    }
                    std.debug.print("{c}", .{char});
                }
                std.debug.print("\n", .{});
            }
        }
    };
}

fn makeStaticGrid(T: anytype, default: T, comptime wide: u32, comptime height: u32) [height][wide]T {
    return .{.{default} ** wide} ** height;
}

fn testGrid() void {
    var screen = StaticGrid(bool, false, 7, 3).init();
    std.debug.print("screen height:{} width:{}\n", .{ screen.height, screen.width });
    screen.putRect(3, 2);
    screen.show();
    std.debug.print("----------------\n", .{});
    screen.rotateColumn(1, 1);
    screen.show();
    std.debug.print("----------------\n", .{});
    screen.rotateRow(0, 4);
    screen.show();
    std.debug.print("----------------\n", .{});
    screen.rotateColumn(1, 1);
    screen.show();
    std.debug.print("----------------\n", .{});
}

pub fn main() !void {
    std.debug.print("day08!\n", .{});
    tagUnion();

    testGrid();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const alloc = arena.allocator();

    try regexTest(alloc);

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day08", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024 * 100);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n
    var lines = std.mem.split(u8, content, "\n");

    var instrctions = std.ArrayList(Instruction).init(alloc);
    while (lines.next()) |l| {
        // std.debug.print("line: {s}\n", .{l});
        const instrction = (try Instruction.parse(alloc, l)).?;
        // std.debug.print("istruction: {any}\n", .{instrction});
        try instrctions.append(instrction);
    }

    var screen = StaticGrid(bool, false, 50, 6).init();
    for (instrctions.items) |i| {
        switch (i) {
            Instruction.Rect => |x| {
                // std.debug.print("rect {}x{}\n", .{ x[0], x[1] });
                screen.putRect(x[0], x[1]);
            },
            Instruction.Rotate => |r| {
                switch (r) {
                    Rotate.Row => |x| {
                        screen.rotateRow(x[0], x[1]);
                    },
                    Rotate.Column => |x| {
                        screen.rotateColumn(x[0], x[1]);
                    },
                }
            },
        }
    }

    // count true
    var sum: u32 = 0;
    for (0..screen.height) |y| {
        for (0..screen.width) |x| {
            if (screen.grid[y][x]) {
                sum += 1;
            }
        }
    }

    std.debug.print("lit: {}\n", .{sum});
    screen.show();
}
