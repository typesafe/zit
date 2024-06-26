const std = @import("std");
const stdout = std.io.getStdOut().writer();
const Objects = @import("../storage/Objects.zig");

pub fn exec(args: [][]const u8) !void {
    const write = std.mem.eql(u8, args[0], "-w");
    _ = write;
    const path = args[1];

    const hash = try Objects.writeBlob(path);
    try stdout.print("{s}\n", .{std.fmt.fmtSliceHexLower(&hash)});
}
