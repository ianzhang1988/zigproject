// --- Day 2: Bathroom Security ---
// You arrive at Easter Bunny Headquarters under cover of darkness. However, you left in such a rush that you forgot to use the bathroom! Fancy office buildings like this one usually have keypad locks on their bathrooms, so you search the front desk for the code.
//
// "In order to improve security," the document you find says, "bathroom codes will no longer be written down. Instead, please memorize and follow the procedure below to access the bathrooms."
//
// The document goes on to explain that each button to be pressed can be found by starting on the previous button and moving to adjacent buttons on the keypad: U moves up, D moves down, L moves left, and R moves right. Each line of instructions corresponds to one button, starting at the previous button (or, for the first line, the "5" button); press whatever button you're on at the end of each line. If a move doesn't lead to a button, ignore it.
//
// You can't hold it much longer, so you decide to figure out the code as you walk to the bathroom. You picture a keypad like this:
//
// 1 2 3
// 4 5 6
// 7 8 9
// Suppose your instructions are:
//
// ULL
// RRDDD
// LURDL
// UUUUD
// You start at "5" and move up (to "2"), left (to "1"), and left (you can't, and stay on "1"), so the first button is 1.
// Starting from the previous button ("1"), you move right twice (to "3") and then down three times (stopping at "9" after two moves and ignoring the third), ending up with 9.
// Continuing from "9", you move left, up, right, down, and left, ending with 8.
// Finally, you move up four times (stopping at "2"), then down once, ending with 5.
// So, in this example, the bathroom code is 1985.
//
// Your puzzle input is the instructions from the document you found at the front desk. What is the bathroom code?
// --- Part Two ---
// You finally arrive at the bathroom (it's a several minute walk from the lobby so visitors can behold the many fancy conference rooms and water coolers on this floor) and go to punch in the code. Much to your bladder's dismay, the keypad is not at all like you imagined it. Instead, you are confronted with the result of hundreds of man-hours of bathroom-keypad-design meetings:
//
//     1
//   2 3 4
// 5 6 7 8 9
//   A B C
//     D
// You still start at "5" and stop when you're at an edge, but given the same instructions as above, the outcome is very different:
//
// You start at "5" and don't move at all (up and left are both edges), ending at 5.
// Continuing from "5", you move right twice and down three times (through "6", "7", "B", "D", "D"), ending at D.
// Then, from "D", you move five more times (through "D", "B", "C", "C", "B"), ending at B.
// Finally, after five more moves, you end at 3.
// So, given the actual keypad layout, the code would be 5DB3.
//
// Using the same instructions in your puzzle input, what is the correctl

const std = @import("std");

const Direction = enum {
    U,
    D,
    L,
    R,
};

fn char2Direction(c: u32) Direction {
    return switch (c) {
        'U' => Direction.U,
        'D' => Direction.D,
        'L' => Direction.L,
        'R' => Direction.R,
        else => unreachable,
    };
}

fn horizontalMove(from: i32, direction: Direction, lower: i32, upper: i32) i32 {
    var to: i32 = from;
    var toTmp: i32 = to;
    if (direction == Direction.L) {
        toTmp -= 1;
        if (toTmp > lower) {
            to = toTmp;
        }
    } else {
        toTmp += 1;
        if (toTmp < upper) {
            to = toTmp;
        }
    }

    return to;
}

pub fn move9pad(from: i32, direction: Direction) i32 {
    var to: i32 = from;
    var toTmp: i32 = to;
    switch (direction) {
        Direction.U => {
            toTmp -= 3;
            if (toTmp > 0) {
                to = toTmp;
            }
        },
        Direction.D => {
            toTmp += 3;
            if (toTmp < 10) {
                to = toTmp;
            }
        },
        Direction.L, Direction.R => {
            switch (from) {
                1, 2, 3 => {
                    to = horizontalMove(from, direction, 0, 4);
                },
                4, 5, 6 => {
                    to = horizontalMove(from, direction, 3, 7);
                },
                7, 8, 9 => {
                    to = horizontalMove(from, direction, 6, 10);
                },
                else => unreachable,
            }
        },
    }

    return to;
}

pub fn realCode(in: i32) u8 {
    const pad = [25]i32{ -1, -1, 1, -1, -1, -1, 2, 3, 4, -1, 5, 6, 7, 8, 9, -1, 10, 11, 12, -1, -1, -1, 13, -1, -1 };
    const code = pad[@intCast(in)];
    return switch (code) {
        1, 2, 3, 4, 5, 6, 7, 8, 9 => '0' + @as(u8, @intCast(code)),
        10, 11, 12, 13 => 'A' + @as(u8, @intCast(code)) - 10,
        else => unreachable,
    };
}

pub fn moveDiamondPad(from: i32, direction: Direction) i32 {
    //     1
    //   2 3 4
    // 5 6 7 8 9
    //   A B C
    //     D
    const pad = [25]i32{ -1, -1, 1, -1, -1, -1, 2, 3, 4, -1, 5, 6, 7, 8, 9, -1, 10, 11, 12, -1, -1, -1, 13, -1, -1 };
    const interval = 5;

    var to: i32 = from;
    var toTmp: i32 = to;

    switch (direction) {
        Direction.U => {
            toTmp -= interval;
            if (toTmp > -1 and pad[@intCast(toTmp)] != -1) {
                to = toTmp;
            }
        },
        Direction.D => {
            toTmp += interval;
            if (toTmp < pad.len and pad[@intCast(toTmp)] != -1) {
                to = toTmp;
            }
        },
        Direction.L => {
            toTmp -= 1;
            if (toTmp > -1 and pad[@intCast(toTmp)] != -1) {
                to = toTmp;
            }
        },
        Direction.R => {
            toTmp += 1;
            if (toTmp < pad.len and pad[@intCast(toTmp)] != -1) {
                to = toTmp;
            }
        },
    }

    return to;
}

pub fn main() !void {
    std.debug.print("day02!\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const file = try (try std.fs.cwd().openDir("day02", .{})).openFile("input", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    std.debug.print("file size: {}\n", .{file_size});

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n

    var instruntionsLine = std.mem.split(u8, content, "\n");

    var pos: i32 = 5;
    for ("ULL") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = move9pad(pos, d);
    }
    std.debug.print("pos: {?}\n", .{pos});

    for ("RRDDD") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = move9pad(pos, d);
    }
    std.debug.print("pos: {?}\n", .{pos});

    for ("LURDL") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = move9pad(pos, d);
    }
    std.debug.print("pos: {?}\n", .{pos});

    for ("UUUUD") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = move9pad(pos, d);
    }
    std.debug.print("pos: {?}\n", .{pos});

    pos = 5;
    while (instruntionsLine.next()) |l| {
        // std.debug.print("line: {s}\n", .{l});
        for (l) |c| {
            const d = char2Direction(c);
            pos = move9pad(pos, d);
        }
        std.debug.print("code: {?}\n", .{pos});
    }

    // part two
    std.debug.print("------ part two -------\n", .{});
    pos = 10;
    for ("ULL") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = moveDiamondPad(pos, d);
        // std.debug.print("pos: {}\n", .{pos});
    }
    std.debug.print("code: {c}\n", .{realCode(pos)});

    for ("RRDDD") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = moveDiamondPad(pos, d);
        // std.debug.print("pos: {}\n", .{pos});
    }
    std.debug.print("code: {c}\n", .{realCode(pos)});

    for ("LURDL") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = moveDiamondPad(pos, d);
    }
    std.debug.print("code: {c}\n", .{realCode(pos)});

    for ("UUUUD") |c| {
        const d = char2Direction(c);
        std.debug.print("char: {?}\n", .{d});
        pos = moveDiamondPad(pos, d);
    }
    std.debug.print("code: {c}\n", .{realCode(pos)});

    pos = 10;
    instruntionsLine.reset();
    while (instruntionsLine.next()) |l| {
        // std.debug.print("line: {s}\n", .{l});
        for (l) |c| {
            const d = char2Direction(c);
            pos = moveDiamondPad(pos, d);
        }
        std.debug.print("p2 code: {c}\n", .{realCode(pos)});
    }
}
