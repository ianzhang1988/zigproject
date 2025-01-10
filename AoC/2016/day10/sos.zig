const std = @import("std");

pub fn makeSliceOfStrings(comptime num: usize, comptime size: usize) type {
    return struct {
        const Self = @This();

        buffer: [num * size + num * @sizeOf([]u8)]u8,
        data: [][]u8 = undefined,
        fba: std.heap.FixedBufferAllocator = undefined,
        allocator: std.mem.Allocator = undefined,

        // only work in return Self{}, not self= Self{} return self, this cause dangling pointer.
        pub fn new() Self {
            return Self{ .buffer = .{0} ** (num * size + num * @sizeOf([]u8)) };
        }

        pub fn init(self: *Self) !void {
            std.debug.print("buffer addr: {*}\n", .{&self.buffer});
            std.debug.print("buffer: {any}\n", .{self.buffer});

            self.fba = std.heap.FixedBufferAllocator.init(&self.buffer);
            self.allocator = self.fba.allocator();

            self.data = try self.allocator.alloc([]u8, num);
            std.debug.print("data addr: {*}\n", .{self.data.ptr});

            for (self.data, 0..) |_, idx| {
                const datatmp = try self.allocator.alloc(u8, size);

                // std.debug.print("data[{d}]  data addr: {*}\n", .{ idx, datatmp.ptr });
                self.data[idx] = datatmp;
                std.debug.print("sos data[{d}] fatptr addr:{*} addr: {*} len:{d}\n", .{ idx, &(self.data[idx]), self.data[idx].ptr, self.data[idx].len });
            }

            std.debug.print("buffer 2: {any}\n", .{self.buffer});
        }

        pub fn clear(self: *Self) void {
            std.debug.print("clear data addr: {*}\n", .{self.data.ptr});
            for (self.data, 0..) |_, idx| {
                std.debug.print("clear data[{d}] fatptr addr:{*} addr: {*} len:{d}\n", .{ idx, &(self.data[idx]), self.data[idx].ptr, self.data[idx].len });
                @memset(self.data[idx], 0);
            }
            std.debug.print("buffer 3: {any}\n", .{self.buffer});
        }
    };
}

// fn makeSliceOfStrings(comptime num: usize, comptime size: usize) type {
//     return struct {
//         const Self = @This();
//
//         buffer: [num][size]u8,
//         data: [][]u8 = undefined,
//
//         fn new() Self {
//             const self = Self{ .buffer = .{.{0} ** size} ** num };
//
//             const slice = [_][]u8{undefined} ** num;
//             std.mem.copyForwards([]u8, slice, self.buffer);
//             // inline for (self.buffer, 0..) |s, idx| {
//             //     slice[idx] = s;
//             // }
//
//             // self.data = self.buffer[0..num];
//
//             // for (self.buffer, 0..) |s, idx| {
//             //     self.data[idx] = &s;
//             // }
//
//             return self;
//         }
//
//         pub fn clear(self: *Self) void {
//             for (self.data, 0..) |_, idx| {
//                 std.debug.print("clear data[{d}] fatptr addr:{*} addr: {*} len:{d}\n", .{ idx, &(self.data[idx]), self.data[idx].ptr, self.data[idx].len });
//                 @memset(self.data[idx], 0);
//             }
//         }
//     };
// }

fn doSomething(_: [][]u8) void {}

pub fn main() !void {
    var sos = makeSliceOfStrings(3, 32).new();
    try sos.init();
    sos.clear();

    std.debug.print("data len:{d} ptr:{*}\n", .{ sos.data.len, sos.data.ptr });

    for (sos.data, 0..) |s, idx| {
        std.debug.print("idx:{d}, addr: {*} len:{d}\n", .{ idx, s.ptr, s.len });
        std.debug.print("print buffer[{d}] fatptr addr:{*} addr: {*} len:{d}\n", .{ idx, &(sos.data[idx]), sos.data[idx].ptr, sos.data[idx].len });
        // std.debug.print("data:{s}\n", .{s});
    }

    doSomething(sos.data);
}
