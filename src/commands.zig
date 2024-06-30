const std = @import("std");
const stdout = std.io.getStdOut().writer();

const commands = .{
    .init = @import("./commands/InitCommand.zig"),
    .cat_file = @import("./commands/CatFileCommand.zig"),
    .hash_object = @import("./commands/HashObjectCommand.zig"),
    .ls_tree = @import("./commands/LsTreeCommand.zig"),
    .write_tree = @import("./commands/WriteTreeCommand.zig"),
};

pub const Command = struct {
    pub fn exec(args: [][]const u8, allocator: std.mem.Allocator) !void {
        if (args.len < 2) {
            return stdout.print("Usage: zit <command>\n", .{});
        }

        if (std.mem.eql(u8, args[1], "init")) {
            return commands.init.exec();
        }

        if (std.mem.eql(u8, args[1], "cat-file")) {
            return commands.cat_file.exec(args[2..]);
        }

        if (std.mem.eql(u8, args[1], "hash-object")) {
            return commands.hash_object.exec(args[2..]);
        }

        if (std.mem.eql(u8, args[1], "ls-tree")) {
            return commands.ls_tree.exec(args[2..], allocator);
        }

        if (std.mem.eql(u8, args[1], "write-tree")) {
            return commands.write_tree.exec(args[2..], allocator);
        }

        return error.InvalidCommand;
    }
};
