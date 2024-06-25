const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn exec() !void {
    const cwd = std.fs.cwd();
    _ = try cwd.makeDir("./.git");
    _ = try cwd.makeDir("./.git/objects");
    _ = try cwd.makeDir("./.git/refs");

    {
        const head = try cwd.createFile("./.git/HEAD", .{});
        defer head.close();
        _ = try head.write("ref: refs/heads/main\n");
    }

    _ = try stdout.print("Initialized git directory\n", .{});
}
