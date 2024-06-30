const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn exec(args: [][]const u8, allocator: std.mem.Allocator) !void {
    const name_only = std.mem.eql(u8, "--name-only", args[0]);
    const id = args[1];

    const cwd = std.fs.cwd();

    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "./.git/objects/{s}/{s}", .{ id[0..2], id[2..] });

    const file = try cwd.openFile(path, .{ .mode = .read_only });
    defer file.close();

    var decompressor = std.compress.zlib.decompressor(file.reader());
    var content = decompressor.reader();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    // payload layout:
    // tree <size>\0<mode> <name>\0<sha><mode> <name>\0<sha><mode> <name>\0<sha>

    const header = try content.readUntilDelimiterAlloc(arena.allocator(), '\x00', 1024);
    _ = header; // `tree <size>`

    while (try content.readUntilDelimiterOrEofAlloc(arena.allocator(), ' ', 1024)) |mode| {
        const name = (try content.readUntilDelimiterOrEofAlloc(arena.allocator(), '\x00', 1024)).?;

        var sha: [20]u8 = undefined;
        _ = try content.read(&sha);

        if (name_only) {
            try stdout.print("{s}\n", .{name});
        } else {
            try stdout.print("{s:0>6} {s} {s}\n", .{ mode, std.fmt.fmtSliceHexLower(&sha), name });
        }
    }
}
