// --- Day 1: No Time for a Taxicab ---
// Santa's sleigh uses a very high-precision clock to guide its movements, and the clock's oscillator is regulated by stars. Unfortunately, the stars have been stolen... by the Easter Bunny. To save Christmas, Santa needs you to retrieve all fifty stars by December 25th.
//
// Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!
//
// You're airdropped near Easter Bunny Headquarters in a city somewhere. "Near", unfortunately, is as close as you can get - the instructions on the Easter Bunny Recruiting Document the Elves intercepted start here, and nobody had time to work them out further.
//
// The Document indicates that you should start at the given coordinates (where you just landed) and face North. Then, follow the provided sequence: either turn left (L) or right (R) 90 degrees, then walk forward the given number of blocks, ending at a new intersection.
//
// There's no time to follow such ridiculous instructions on foot, though, so you take a moment and work out the destination. Given that you can only walk on the street grid of the city, how far is the shortest path to the destination?
//
// For example:
//
// Following R2, L3 leaves you 2 blocks East and 3 blocks North, or 5 blocks away.
// R2, R2, R2 leaves you 2 blocks due South of your starting position, which is 2 blocks away.
// R5, L5, R5, R3 leaves you 12 blocks away.
// How many blocks away is Easter Bunny HQ?

// --- Part Two ---
// Then, you notice the instructions continue on the back of the Recruiting Document. Easter Bunny HQ is actually at the first location you visit twice.
//
// For example, if your instructions are R8, R4, R4, R8, the first location you visit twice is 4 blocks away, due East.
//
// How many blocks away is the first location you visit twice?
//
const std = @import("std");
const ArrayList = std.ArrayList;

const Direction = enum(usize) {
    North,
    East,
    Sourth,
    West,
};

const LoR = enum {
    Left,
    Right,
    None,
};

const Instruction = struct {
    lor: LoR = LoR.None,
    step: i32 = 0,
};

const Point = struct {
    x: i32 = 0,
    y: i32 = 0,
};

const Path = struct {
    start: Point,
    end: Point,
};

pub fn splitInst(instStr: []const u8) Instruction {
    var inst = Instruction{};

    switch (instStr[0]) {
        'L' => inst.lor = LoR.Left,
        'R' => inst.lor = LoR.Right,
        else => {},
    }

    const numStr = instStr[1..instStr.len];

    inst.step = std.fmt.parseInt(i32, numStr, 10) catch 0;

    return inst;
}

// https://www.cnblogs.com/xpvincent/p/5208994.html
pub fn isIntersect(p1: Path, p2: Path) ?Point {
    const a1 = p1.end.y - p1.start.y;
    const b1 = p1.start.x - p1.end.x;
    const c1 = a1 * p1.start.x + b1 * p1.start.y;

    const a2 = p2.end.y - p2.start.y;
    const b2 = p2.start.x - p2.end.x;
    const c2 = a2 * p2.start.x + b2 * p2.start.y;

    const det = a1 * b2 - a2 * b1;

    if (det == 0) {
        return null;
    } else {
        // const x = (c1 * b2 - c2 * b1) / det;
        // const y = (a1 * c2 - a2 * c1) / det;
        const x = @divExact(c1 * b2 - c2 * b1, det);
        const y = @divExact(a1 * c2 - a2 * c1, det);
        return Point{ .x = x, .y = y };
    }
}

pub fn main() !void {
    const file = try (try std.fs.cwd().openDir("day01", .{})).openFile("input", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const contentT = try file.reader().readAllAlloc(alloc, 1024 * 1024);
    const content = contentT[0 .. contentT.len - 1]; // remove newline
    // _ = content;
    const contentTest = "R5, L5, R5, R3, R12";
    _ = contentTest;

    var instruntions = std.mem.split(u8, content, ", ");

    var direction = Direction.North;
    var directionStep = [_]i32{0} ** 4;

    var paths = ArrayList(Path).init(alloc);
    var startPoint = Point{ .x = 0, .y = 0 };

    while (instruntions.next()) |i| {
        // std.debug.print("i:{s}\n", .{i});
        const inst = splitInst(i);
        // std.debug.print("{}: {}\n", .{ inst.lor, inst.step });

        const diInt = @intFromEnum(direction);
        switch (inst.lor) {
            LoR.Left => {
                direction = @enumFromInt((diInt + 3) % 4);
            },
            LoR.Right => {
                direction = @enumFromInt((diInt + 1) % 4);
            },
            LoR.None => std.debug.print("should never reach\n", .{}),
        }

        const diNewInt = @intFromEnum(direction);
        directionStep[diNewInt] += inst.step;

        var newEnd = Point{};
        switch (direction) {
            Direction.East => {
                newEnd.x = startPoint.x + inst.step;
                newEnd.y = startPoint.y;
            },
            Direction.West => {
                newEnd.x = startPoint.x - inst.step;
                newEnd.y = startPoint.y;
            },
            Direction.North => {
                newEnd.x = startPoint.x;
                newEnd.y = startPoint.y + inst.step;
            },
            Direction.Sourth => {
                newEnd.x = startPoint.x;
                newEnd.y = startPoint.y - inst.step;
            },
        }

        try paths.append(Path{ .start = startPoint, .end = newEnd });

        startPoint = newEnd;
    }

    for (directionStep, 0..) |s, d| {
        const di: Direction = @enumFromInt(d);
        std.debug.print("{}: {}\n", .{ di, s });
    }

    const x = @abs(directionStep[1] - directionStep[3]);
    const y = @abs(directionStep[0] - directionStep[2]);

    const blocks = x + y;
    std.debug.print("x:{}, y:{}, blocks:{}\n", .{ x, y, blocks });

    for (0..3) |i| {
        const path = paths.items[i];
        std.debug.print("start({}, {}), end({}, {})\n", .{ path.start.x, path.start.y, path.end.x, path.end.y });
    }

    var intersectionX: i32 = 0;
    var intersectionY: i32 = 0;

    for (0..paths.items.len) |i| {
        const curPath = paths.items[i];
        for (0..i) |j| {
            const comparePath = paths.items[j];
            const result = isIntersect(curPath, comparePath);
            if (result != null) {
                const pt = result.?;
                intersectionY = pt.y;
                intersectionX = pt.x;
                break;
            }
        }
    }

    std.debug.print("x:{}, y:{}/n", .{ intersectionX, intersectionY });
}
