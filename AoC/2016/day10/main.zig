// --- Day 10: Balance Bots ---
// You come upon a factory in which many robots are zooming around handing small microchips to each other.
//
// Upon closer examination, you notice that each bot only proceeds when it has two microchips, and once it does, it gives each one to a different bot or puts it in a marked "output" bin. Sometimes, bots take microchips from "input" bins, too.
//
// Inspecting one of the microchips, it seems like they each contain a single number; the bots must use some logic to decide what to do with each chip. You access the local control computer and download the bots' instructions (your puzzle input).
//
// Some of the instructions specify that a specific-valued microchip should be given to a specific bot; the rest of the instructions indicate what a given bot should do with its lower-value or higher-value chip.
//
// For example, consider the following instructions:
//
// value 5 goes to bot 2
// bot 2 gives low to bot 1 and high to bot 0
// value 3 goes to bot 1
// bot 1 gives low to output 1 and high to bot 0
// bot 0 gives low to output 2 and high to output 0
// value 2 goes to bot 2
// Initially, bot 1 starts with a value-3 chip, and bot 2 starts with a value-2 chip and a value-5 chip.
// Because bot 2 has two microchips, it gives its lower one (2) to bot 1 and its higher one (5) to bot 0.
// Then, bot 1 has two microchips; it puts the value-2 chip in output 1 and gives the value-3 chip to bot 0.
// Finally, bot 0 has two microchips; it puts the 3 in output 2 and the 5 in output 0.
// In the end, output bin 0 contains a value-5 microchip, output bin 1 contains a value-2 microchip, and output bin 2 contains a value-3 microchip. In this configuration, bot number 2 is responsible for comparing value-5 microchips with value-2 microchips.
//
// Based on your instructions, what is the number of the bot that is responsible for comparing value-61 microchips with value-17 microchips?

const std = @import("std");
const Regex = @import("regex").Regex;

const Input = struct {
    value: u32,
    botNum: usize,
};

const Operation = struct {
    highTo: usize,
    lowTo: usize,

    pub fn apply(self: Operation, bot: Bot, allBots: *[1000]Bot) !void {
        var highChip = bot.Chips[0];
        var lowChip = bot.Chips[1];
        if (highChip < lowChip) {
            std.mem.swap(u32, &highChip, &lowChip);
        }
        allBots[self.highTo].addChip(highChip);
        allBots[self.lowTo].addChip(highChip);
    }
};

const Bot = struct {
    Id: usize,
    ChipIdx: usize,
    Chips: [2]u32,
    ops: Operation,

    pub fn addChip(self: *Bot, chip: u32) void {
        self.Chips[self.ChipIdx] = chip;
        self.ChipIdx += 1;
        std.debug.assert(self.ChipIdx <= 2);
    }

    pub fn ready(self: Bot) bool {
        return self.ChipIdx == 2;
    }
};

fn extract(alloc: std.mem.Allocator, comptime regex: []const u8, in: []const u8, comptime num: usize, output: *[][]u8) !bool {
    // std.debug.print("regex: {s}\n", .{regex});
    // std.debug.print("in: {s}\n", .{in});
    var re = try Regex.compile(alloc, regex);
    defer re.deinit();

    const capOp = try re.captures(in);

    if (capOp == null) {
        return false;
    }

    // var params: [2]u32 = .{ 0, 0 };

    const cap = capOp.?;

    for (0..num) |i| {
        const tmpStr = cap.sliceAt(i + 1);
        if (tmpStr == null) {
            continue;
        }
        // std.debug.print("column num: {s}\n", .{numOp.?});
        // output.*[i] = tmpStr.?;
        std.mem.copyForwards(u8, output.*[i], tmpStr.?);
    }

    return true;
}

// const SliceOfStrings = struct {
//     buffer: []
//     data: [][]u8,
//     alloc: std.mem.Allocator,
//
//     pub fn deinit(self: *SliceOfStrings) void {
//         for (self.data, 0..) |_, idx| {
//             self.alloc.free(self.data[idx]);
//         }
//
//         self.alloc.free(self.data);
//     }
// };
//
// fn makeSliceOfStrings(comptime num: usize, comptime size: usize) !SliceOfStrings {
//     var sfa = std.heap.StackFallbackAllocator(num * size + num * @sizeOf([]u8)){};
//     var sfalloc = sfa.get();
//
//     var sos = SliceOfStrings{
//         .alloc = sfalloc,
//     };
//
//     sos.data = try sfalloc.alloc([]u8, num);
//
//     for (sos.data, 0..) |_, idx| {
//         sos.data[idx] = try sfalloc.alloc(u8, size);
//     }
//
//     return sos;
// }

fn makeSliceOfStrings(comptime num: usize, comptime size: usize) type {
    return struct {
        const Self = @This();

        buffer: [num * size + num * @sizeOf([]u8)]u8,
        data: [][]u8 = undefined,
        fba: std.heap.FixedBufferAllocator = undefined,
        allocator: std.mem.Allocator = undefined,

        pub fn new() !Self {
            var self = Self{ .buffer = .{0} ** (num * size + num * @sizeOf([]u8)) };
            std.debug.print("buffer addr: {*}\n", .{&self.buffer});
            std.debug.print("buffer: {any}\n", .{self.buffer});

            self.fba = std.heap.FixedBufferAllocator.init(&self.buffer);
            self.allocator = self.fba.allocator();

            self.data = try self.allocator.alloc([]u8, num);
            std.debug.print("data addr: {*}\n", .{self.data.ptr});

            for (self.data, 0..) |_, idx| {
                const datatmp = try self.allocator.alloc(u8, size);

                std.debug.print("buffer[{d}]  data addr: {*}\n", .{ idx, datatmp.ptr });
                self.data[idx] = datatmp;
                std.debug.print("sos buffer[{d}] fatptr addr:{*} addr: {*} len:{d}\n", .{ idx, &(self.data[idx]), self.data[idx].ptr, self.data[idx].len });
            }

            std.debug.print("buffer 2: {any}\n", .{self.buffer});

            return self;
        }

        pub fn clear(self: *Self) void {
            std.debug.print("clear data addr: {*}\n", .{self.data.ptr});
            for (self.data, 0..) |_, idx| {
                std.debug.print("clear buffer[{d}] fatptr addr:{*} addr: {*} len:{d}\n", .{ idx, &(self.data[idx]), self.data[idx].ptr, self.data[idx].len });
                // @memset(self.data[idx], 0);
            }
            std.debug.print("buffer 3: {any}\n", .{self.buffer});
        }
    };
}

pub fn parse(alloc: std.mem.Allocator, line: []const u8) !void {
    // var tmpData: [2][256]u8 = .{.{0} ** 256} ** 2;
    // // std.debug.print("type {?}\n", .{@TypeOf(tmpData[0])});
    // // var data = [2][]u8{ tmpData[0][0..], tmpData[1] };
    // // !!! tmpData[0][0..] gives *const [256]u8, not a slice. so must be some compiler thingy
    // var data: [2][]u8 = undefined;
    // data[0] = tmpData[0][0..];
    // data[1] = tmpData[1][0..];
    //
    // if (try extract(alloc, "value (\\d+) goes to bot (\\d+)", line, 2, &data)) {
    //     std.debug.print("chip:{s}, bot:{s}\n", .{ data[0], data[1] });
    // }

    var sos = try makeSliceOfStrings(10, 32).new();
    sos.clear();

    std.debug.print("data len:{d}\n", .{sos.data.len});

    for (sos.data, 0..) |s, idx| {
        std.debug.print("idx:{d}, len:{d}, type:{?}\n", .{ idx, s.len, @TypeOf(s) });
        // std.debug.print("data:{s}\n", .{s});
    }

    if (try extract(alloc, "value (\\d+) goes to bot (\\d+)", line, 2, &sos.data)) {
        std.debug.print("chip:{s}, bot:{s}\n", .{ sos.data[0], sos.data[1] });
    }

    // if (try extract(alloc, "bot (\\d+) gives low to (\\w+) (\\d+) and high to (\\w+) (\\d+)", line, 5, &data)) {
    //     std.debug.print("bot:{s} low-{s} chip:{s}, high-{s} chip:{s}\n", .{ data[0], data[1], data[2], data[3], data[4] });
    // }
}

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

    //var allBots = [_]Bot{} * 1000;
    c = 0;
    lines.reset();
    while (lines.next()) |l| : (c += 1) {
        if (c > 0) {
            break;
        }
        try parse(alloc, l);
    }
}
