// https://ziggit.dev/t/i-want-to-assign-stack-alloced-num-size-u8-to-u8-but-encountered-memory-problem-please-help/7783/5

const std = @import("std");

fn ManyBuffer(comptime num: u32, comptime size: u32) type {
    return struct {
        const Self = @This();

        const Part = struct {
            start: u32,
            len: u32,
        };

        buffer: [num * size]u8,
        parts: [num]Part,

        pub fn init() Self {
            // + this shuld give space to buffer and parts in stack
            var self: Self = undefined;
            // + give them value
            self.reset();
            return self;
        }

        pub fn reset(self: *Self) void {
            @memset(&self.buffer, 0);

            var start: u32 = 0;
            for (&self.parts) |*dest| {
                dest.* = .{ .start = start, .len = size };
                start += size;
            }
        }

        // slices can be called to create an array of slices when it is needed
        // (and where it is needed / you can put it somewhere on the stack),
        // this avoids doing unnecessary work (when we don't need slices) and self-referential pointers
        // in moving structs
        pub fn slices(self: *Self) [num][]u8 {
            var res: [num][]u8 = undefined;
            for (&res, self.parts) |*dest, part| dest.* = self.buffer[part.start..][0..part.len];
            return res;
        }

        pub fn resize(self: *Self, index: usize, len: usize) void {
            std.debug.assert(len <= size);
            self.parts[index].len = @intCast(len);
        }
    };
}

fn doSomething(_: []const []u8) void {}

pub fn main() !void {
    var mb = ManyBuffer(3, 32).init();

    for (mb.slices(), 0..) |s, idx| {
        const res = try std.fmt.bufPrint(s, "{d} element", .{idx});
        std.debug.print("res.len: {}\n", .{res.len});
        std.debug.print("idx:{d}, addr: {*} len:{d} contents: {s}\n", .{ idx, s.ptr, s.len, s });

        // now we can update part.len to res.len to store the true length of the used string
        mb.resize(idx, res.len);
    }

    // call slices again to get slices with used string size,
    // if we aren't interested in used length we would use the result of the first call
    const slices = mb.slices();
    std.debug.print("used length\n", .{});
    for (slices, 0..) |s, idx| {
        std.debug.print("idx:{d}, addr: {*} len:{d} contents: {s}\n", .{ idx, s.ptr, s.len, s });
    }
    doSomething(&slices);

    mb.reset();
    std.debug.print("reset\n", .{});
    for (mb.slices(), 0..) |s, idx| {
        std.debug.print("idx:{d}, addr: {*} len:{d} contents: {s}\n", .{ idx, s.ptr, s.len, s });
    }
}
