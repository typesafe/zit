const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn exec(id: []const u8) !void {
    const cwd = std.fs.cwd();
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try std.fmt.bufPrint(&buf, "./.git/objects/{s}/{s}", .{ id[0..2], id[2..] });

    const file = try cwd.openFile(path, .{ .mode = .read_only });
    defer file.close();

    var content = std.compress.zlib.decompressor(file.reader());

    while (true) {
        const b = try content.get(1);
        if (b[0] == 0) {
            break;
        }
    }

    while (try content.next()) |b| {
        _ = try stdout.write(b);
    }
}
