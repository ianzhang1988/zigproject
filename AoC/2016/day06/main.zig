// --- Day 6: Signals and Noise ---
// Something is jamming your communications with Santa. Fortunately, your signal is only partially jammed, and protocol in situations like this is to switch to a simple repetition code to get the message through.
//
// In this model, the same message is sent repeatedly. You've recorded the repeating message signal (your puzzle input), but the data seems quite corrupted - almost too badly to recover. Almost.
//
// All you need to do is figure out which character is most frequent for each position. For example, suppose you had recorded the following messages:
//
// eedadn
// drvtee
// eandsr
// raavrd
// atevrs
// tsrnev
// sdttsa
// rasrtv
// nssdts
// ntnada
// svetve
// tesnvt
// vntsnd
// vrdear
// dvrsen
// enarar
// The most common character in the first column is e; in the second, a; in the third, s, and so on. Combining these characters returns the error-corrected message, easter.
//
// Given the recording in your puzzle input, what is the error-corrected version of the message being sent?
//
// --- Part Two ---
// Of course, that would be the message - if you hadn't agreed to use a modified repetition code instead.
//
// In this modified code, the sender instead transmits what looks like random data, but for each character, the character they actually want to send is slightly less likely than the others. Even after signal-jamming noise, you can look at the letter distributions in each column and choose the least common letter to reconstruct the original message.
//
// In the above example, the least common character in the first column is a; in the second, d, and so on. Repeating this process for the remaining characters produces the original message, advent.
//
// Given the recording in your puzzle input and this new decoding methodology, what is the original message that Santa is trying to send?

const std = @import("std");

pub fn main() !void {
    std.debug.print("day05!\n", .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day06", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n
    var lines = std.mem.split(u8, content, "\n");

    // const testInput =
    //     \\eedadn
    //     \\drvtee
    //     \\eandsr
    //     \\raavrd
    //     \\atevrs
    //     \\tsrnev
    //     \\sdttsa
    //     \\rasrtv
    //     \\nssdts
    //     \\ntnada
    //     \\svetve
    //     \\tesnvt
    //     \\vntsnd
    //     \\vrdear
    //     \\dvrsen
    //     \\enarar
    // ;
    // var lines = std.mem.splitSequence(u8, testInput, "\n");

    var length: i32 = 0;
    var num: i32 = 0;

    while (lines.next()) |l| {
        length = @intCast(l.len);
        num += 1;
        // std.debug.print("line: {s}\n", .{l});
    }
    lines.reset();

    var counterArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer counterArena.deinit();
    const counterAlloc = counterArena.allocator();

    var counterForColumn = std.ArrayList(std.AutoArrayHashMap(u8, u32)).init(counterAlloc);
    for (0..@intCast(length)) |_| {
        try counterForColumn.append(std.AutoArrayHashMap(u8, u32).init(counterAlloc));
    }

    while (lines.next()) |l| {
        for (0..@intCast(length)) |i| {
            if (counterForColumn.items[i].get(l[i])) |sum| {
                try counterForColumn.items[i].put(l[i], sum + 1);
            } else {
                try counterForColumn.items[i].put(l[i], 1);
            }
        }
    }

    var correctWord: []u8 = try alloc.alloc(u8, @intCast(length));
    defer alloc.free(correctWord);
    var correctWordP2: []u8 = try alloc.alloc(u8, @intCast(length));
    defer alloc.free(correctWordP2);

    for (counterForColumn.items, 0..) |counterMap, i| {
        var it = counterMap.iterator();
        var max: u32 = 0;
        var char: u8 = 0;
        var least: u32 = 99999999;
        var charP2: u8 = 0;
        while (it.next()) |e| {
            const k = e.key_ptr.*;
            const sum = e.value_ptr.*;
            if (sum > max) {
                max = sum;
                char = k;
            }
            if (sum < least) {
                least = sum;
                charP2 = k;
            }
        }
        correctWord[i] = char;
        correctWordP2[i] = charP2;
    }

    std.debug.print("correctWord: {s}\n", .{correctWord});
    std.debug.print("correctWord part2: {s}\n", .{correctWordP2});
}
