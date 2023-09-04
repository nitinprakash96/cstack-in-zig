const std = @import("std");
const Allocator = std.mem.Allocator;
const os = std.os;
const io = std.io;
const process = std.process;
const expect = std.testing.expect;

fn read_input() ![]const u8 {
    const stdin = std.io.getStdIn().reader();

    var buf: [1024]u8 = undefined;

    // TODO: use `streamUntilDelimiter` instead
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return user_input;
    } else {
        return error.EndOfStream;
    }
}

pub fn print_prompt() void {
    std.debug.print("db > ", .{});
}

pub fn main() !void {
    while (true) {
        _ = print_prompt();

        const command = try read_input();
        const exit_command = ".exit";

        if (std.mem.eql(u8, command, exit_command)) {
            process.exit(0);
        } else {
            std.debug.print("Unrecognized command {s}\n", .{command});
        }
    }
}

test "slices" {
    const msg = try read_input();
    const input = ".exit";
    std.debug.print("{s}, {s}\n", .{ msg, input });
    try std.testing.expect(std.mem.eql(u8, msg, input));
}
