const std = @import("std");
const stdout = std.io.getStdOut().writer();
const Objects = @import("../storage/Objects.zig");

pub fn exec(_: [][]const u8, allocator: std.mem.Allocator) !void {
    const hash = try Objects.writeTree(".", allocator);
    try stdout.print("{s}\n", .{std.fmt.fmtSliceHexLower(&hash)});
}
