const std = @import("std");
const stdout = std.io.getStdOut().writer();
const Objects = @import("../storage/Objects.zig");

pub fn exec(args: [][]const u8, allocator: std.mem.Allocator) !void {
    var parent: ?[]const u8 = null;
    var message: ?[]const u8 = null;

    var i: u32 = 1;
    while (i < args.len) {
        const arg = args[i];
        i += 1;
        if (args.len <= i) {
            break;
        }

        if (std.mem.eql(u8, arg, "-p")) {
            parent = args[i];
        } else if (std.mem.eql(u8, arg, "-m")) {
            message = args[i];
        }

        i += 1;
    }

    const hash = try Objects.commitTree(args[0], .{
        .parent = parent,
        .message = message.?,
    }, allocator);

    try stdout.print("{s}\n", .{std.fmt.fmtSliceHexLower(&hash)});
}
