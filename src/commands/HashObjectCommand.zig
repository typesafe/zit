const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn exec(args: [][]const u8) !void {
    const write = std.mem.eql(u8, args[0], "-w");
    const path = args[1];
    const cwd = std.fs.cwd();

    const source_file = cwd.openFile(path, .{ .mode = .read_only }) catch |err| {
        switch (err) {
            error.FileNotFound => std.debug.print("fatal: could not open '{s}' for reading: No such file or directory", .{path}),
            else => std.debug.print("fatal: could not open '{s}' for reading: {}", .{ path, err }),
        }
        return;
    };
    defer source_file.close();

    const reader = source_file.reader();

    var sha1 = std.crypto.hash.Sha1.init(.{});
    try sha1.writer().print("blob {}\x00", .{try source_file.getEndPos()});

    var buffer: [1024]u8 = undefined;

    const hash = while (true) {
        const count = try reader.read(&buffer);
        if (count == 0) {
            break sha1.finalResult();
        }
        sha1.update(buffer[0..count]);
    };

    if (write) {
        var buf: [std.fs.max_path_bytes]u8 = undefined;
        const target_path = try std.fmt.bufPrint(&buf, "./.git/objects/{s}/{s}", .{ std.fmt.fmtSliceHexLower(hash[0..1]), std.fmt.fmtSliceHexLower(hash[1..]) });
        const dir = target_path[0..17];
        cwd.makeDir(dir) catch |err| {
            switch (err) {
                error.PathAlreadyExists => {},
                else => return err,
            }
        };

        const target_file = try cwd.createFile(target_path, .{ .truncate = true });
        defer target_file.close();

        try reader.context.seekTo(0);

        var content = try std.compress.zlib.compressor(target_file.writer(), .{});

        try content.writer().print("blob {}\x00", .{try source_file.getEndPos()});

        while (true) {
            const count = try reader.read(&buffer);
            if (count == 0) {
                try content.finish();
                break;
            }
            _ = try content.write(buffer[0..count]);
        }

        try stdout.print("{s}\n", .{std.fmt.fmtSliceHexLower(&hash)});
    }
}
