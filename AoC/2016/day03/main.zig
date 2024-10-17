// Now that you can think clearly, you move deeper into the labyrinth of hallways and office furniture that makes up this part of Easter Bunny HQ. This must be a graphic design department; the walls are covered in specifications for triangles.
//
// Or are they?
//
// The design document gives the side lengths of each triangle it describes, but... 5 10 25? Some of these aren't triangles. You can't help but mark the impossible ones.
//
// In a valid triangle, the sum of any two sides must be larger than the remaining side. For example, the "triangle" given above is impossible, because 5 + 10 is not larger than 25.
//
// In your puzzle input, how many of the listed triangles are possible?
// --- Part Two ---
// Now that you've helpfully marked up their design documents, it occurs to you that triangles are specified in groups of three vertically. Each set of three numbers in a column specifies a triangle. Rows are unrelated.
//
// For example, given the following specification, numbers with the same hundreds digit would be part of the same triangle:
//
// 101 301 501
// 102 302 502
// 103 303 503
// 201 401 601
// 202 402 602
// 203 403 603
// In your puzzle input, and instead reading by columns, how many of the listed triangles are possible?

const std = @import("std");

fn splitNum(data: []const u8) [3]u32 {
    var nums = [_]u32{0} ** 3;
    var numPos: usize = 0;
    var numStr = [_]u8{0} ** 32;
    @memset(&numStr, 0);
    var pos: usize = 0;

    for (data) |c| {
        if (c >= '0' and c <= '9') {
            numStr[pos] = c;
            pos += 1;
        } else {
            if (pos > 0) {
                nums[numPos] = std.fmt.parseInt(u32, numStr[0..pos], 10) catch 0;
                numPos += 1;
            }

            pos = 0;
            @memset(&numStr, 0);
        }
    }

    if (pos > 0) {
        nums[numPos] = std.fmt.parseInt(u32, numStr[0..pos], 10) catch 0;
    }

    return nums;
}

pub fn main() !void {
    std.debug.print("day03!\n", .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const file = try (try std.fs.cwd().openDir("day03", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n

    var lines = std.mem.split(u8, content, "\n");

    var counter: i32 = 0;
    while (lines.next()) |l| {
        std.debug.print("line: {s}\n", .{l});
        const nums = splitNum(l);
        std.debug.print("nums: {any}\n", .{nums});

        var isTriangle = false;
        if (nums[0] < nums[1] + nums[2]) {
            if (nums[1] >= nums[2]) {
                if (nums[0] + nums[2] > nums[1]) {
                    isTriangle = true;
                }
            } else {
                if (nums[0] + nums[1] > nums[2]) {
                    isTriangle = true;
                }
            }
        }

        if (isTriangle) {
            std.debug.print("good nums: {any}\n", .{nums});
            counter += 1;
        }
    }

    std.debug.print("num: {}\n", .{counter});
}
