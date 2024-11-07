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

const std = @import("std");
const Regex = @import("regex").Regex;

pub fn main() !void {
    std.debug.print("day07!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const alloc = arena.allocator();

    // const file = try (try std.fs.cwd().openDir("day04", .{})).openFile("test", .{});
    const file = try (try std.fs.cwd().openDir("day08", .{})).openFile("input", .{});
    defer file.close();

    const contentTmp = try file.reader().readAllAlloc(alloc, 1024 * 1024 * 100);
    defer alloc.free(contentTmp);
    const content = contentTmp[0 .. contentTmp.len - 1]; // vim keep last \n
    var lines = std.mem.split(u8, content, "\n");

    while (lines.next()) |l| {
        std.debug.print("line: {s}\n", .{l});
    }

    var re = try Regex.compile(alloc, "rect (\\d+)x(\\d+)");
    const cap = try re.captures("rect 3x2");

    std.debug.print("cap? {}\n", .{cap != null});
    // if (cap) |c| {
    // }
}