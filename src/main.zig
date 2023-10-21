const std = @import("std");
const Allocator = std.mem.Allocator;
const os = std.os;
const io = std.io;
const process = std.process;
const expect = std.testing.expect;

const InputBuffer = struct {
    buffer: [128]u8,
};

const MetaCommandResult = enum {
    metaSuccess,
    metaUnrecognizedCommand,
};

const PrepareResult = enum {
    prepareSuccess,
    // TOOO: this needs to be an exception in the logic
    prepareUnrecognizedCommand,
};

const StatementType = enum {
    stmtSelect,
    stmtInsert,
};

const Statement = struct {
    stype: StatementType,
};

fn do_meta_command(input_buffer: []const u8) MetaCommandResult {
    const exit_command = ".exit";

    if (std.mem.eql(u8, input_buffer, exit_command)) {
        return MetaCommandResult.metaSuccess;
    }
    return MetaCommandResult.metaUnrecognizedCommand;
}

fn read_input() ![]const u8 {
    const stdin = std.io.getStdIn().reader();

    var buf: [124]u8 = undefined;

    // TODO: use `streamUntilDelimiter` instead
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return user_input;
    } else {
        return error.EndOfStream;
    }
}

fn prepare_statement(input_buffer: []const u8, statement: *Statement) PrepareResult {
    if (std.mem.eql(u8, input_buffer, "insert")) {
        statement.*.stype = StatementType.stmtInsert;
        return PrepareResult.prepareSuccess;
    }
    if (std.mem.eql(u8, input_buffer, "select")) {
        statement.*.stype = StatementType.stmtSelect;
        return PrepareResult.prepareSuccess;
    }

    return PrepareResult.prepareUnrecognizedCommand;
}

fn execute_statement(statement: *Statement) void {
    switch (statement.*.stype) {
        .stmtSelect => |_| {
            std.debug.print("This is a SELECT statement\n", .{});
        },
        .stmtInsert => |_| {
            std.debug.print("This is a INSERT statement\n", .{});
        },
    }
}

pub fn print_prompt() void {
    std.debug.print("db > ", .{});
}

pub fn main() !void {
    while (true) {
        _ = print_prompt();

        const input_buffer = try read_input();

        if (input_buffer[0] == '.') {
            const result = do_meta_command(input_buffer);
            switch (result) {
                .metaSuccess => |_| {
                    os.exit(0);
                },
                .metaUnrecognizedCommand => |_| {
                    std.debug.print("Unrecognized command\n", .{});
                    continue;
                },
            }
        }

        var statement: Statement = undefined;
        const prep_statement = prepare_statement(input_buffer, &statement);
        switch (prep_statement) {
            .prepareSuccess => |_| {
                execute_statement(&statement);
            },
            .prepareUnrecognizedCommand => |_| {
                std.debug.print("Unrecognized keyword: {s}\n", .{input_buffer});
            },
        }
    }
}
