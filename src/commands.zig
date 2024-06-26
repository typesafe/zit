const std = @import("std");
const stdout = std.io.getStdOut().writer();

const commands = .{
    .init = @import("./commands/InitCommand.zig"),
    .cat_file = @import("./commands/CatFileCommand.zig"),
};

pub const Command = struct {
    pub fn exec(args: [][]const u8) !void {
        if (args.len < 2) {
            return stdout.print("Usage: zit <command>\n", .{});
        }

        if (std.mem.eql(u8, args[1], "init")) {
            return commands.init.exec();
        }

        if (std.mem.eql(u8, args[1], "cat-file")) {
            return commands.cat_file.exec(args[2..]);
        }

        return error.InvalidCommand;
    }
};
