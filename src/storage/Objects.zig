const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub const CommitOptions = struct {
    message: []const u8,
    parent: ?[]const u8 = null,
};

pub fn commitTree(tree_hash: []const u8, options: CommitOptions, allocator: std.mem.Allocator) ![20]u8 {
    var cwd = std.fs.cwd();
    var content = std.ArrayList(u8).init(allocator);
    defer content.deinit();

    const writer = content.writer();

    try writer.print("tree {s}\n", .{tree_hash});
    if (options.parent) |p| {
        try writer.print("parent {s}\n", .{p});
    }
    try writer.print("author Gino Heyman <gino.heyman@gmail.com> {} +0100\n", .{std.time.epoch});
    try writer.print("committer  Gino Heyman <gino.heyman@gmail.com> {} +0100\n", .{std.time.epoch});
    try writer.print("\n{s}\n", .{options.message});

    const size: usize = content.items.len;

    var sha1 = std.crypto.hash.Sha1.init(.{});
    try sha1.writer().print("commit {}\x00", .{size});
    sha1.update(content.items);
    const hash = sha1.finalResult();

    const target_path = try getObjectPath(hash);
    const dir = target_path[0..17];
    cwd.makeDir(dir) catch |err| {
        switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        }
    };

    const target_file = try cwd.createFile(&target_path, .{ .truncate = true });
    defer target_file.close();

    var comp = try std.compress.zlib.compressor(target_file.writer(), .{});
    try comp.writer().print("commit {}\x00", .{size});
    _ = try comp.write(content.items);
    try comp.finish();

    return hash;
}

pub fn writeTree(path: []const u8, allocator: std.mem.Allocator) ![20]u8 {
    var cwd = std.fs.cwd();

    var list = std.ArrayList(ObjectEntry).init(allocator);
    defer list.deinit();
    var sub_path = std.ArrayList(u8).init(allocator);
    defer sub_path.deinit();

    try sub_path.appendSlice(path);

    const d = try cwd.openDir(path, .{ .iterate = true });
    var it = d.iterate();

    while (try it.next()) |entry| {
        if (std.mem.eql(u8, entry.name, ".git")) {
            continue;
        }

        try sub_path.append('/');
        try sub_path.appendSlice(entry.name);

        switch (entry.kind) {
            .directory => {
                try list.append(.{ .mode = "40000", .name = entry.name, .hash = try writeTree(sub_path.items, allocator) });
            },
            .file => {
                try list.append(.{ .mode = "100644", .name = entry.name, .hash = try writeBlob(sub_path.items) });
            },
            else => return error.UnsupportedDirectoryEntry,
        }

        sub_path.shrinkRetainingCapacity(sub_path.items.len - 1 - entry.name.len);
    }

    std.mem.sort(ObjectEntry, list.items, {}, ObjectEntry.compare);

    var size: usize = 0;
    for (list.items) |item| {
        size += item.mode.len + 1 + item.name.len + 1 + item.hash.len;
    }

    var sha1 = std.crypto.hash.Sha1.init(.{});
    try sha1.writer().print("tree {}\x00", .{size});

    for (list.items) |item| {
        sha1.update(item.mode);
        sha1.update(" ");
        sha1.update(item.name);
        sha1.update(&[_]u8{0});
        sha1.update(&item.hash);
    }
    const hash = sha1.finalResult();

    const target_path = try getObjectPath(hash);
    const dir = target_path[0..17];
    cwd.makeDir(dir) catch |err| {
        switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        }
    };

    const target_file = try cwd.createFile(&target_path, .{ .truncate = true });
    defer target_file.close();

    var content = try std.compress.zlib.compressor(target_file.writer(), .{});

    try content.writer().print("tree {}\x00", .{size});

    for (list.items) |item| {
        _ = try content.write(item.mode);
        _ = try content.write(" ");
        _ = try content.write(item.name);
        _ = try content.write(&[_]u8{0});
        _ = try content.write(&item.hash);
    }

    try content.finish();

    return hash;
}

pub const ObjectEntry = struct {
    mode: []const u8,
    name: []const u8,
    hash: [20]u8,

    pub fn compare(_: void, lhs: ObjectEntry, rhs: ObjectEntry) bool {
        return std.mem.order(u8, lhs.name, rhs.name).compare(std.math.CompareOperator.lt);
    }
};

pub fn writeBlob(path: []const u8) ![20]u8 {
    const cwd = std.fs.cwd();

    const source_file = cwd.openFile(path, .{ .mode = .read_only }) catch |err| {
        switch (err) {
            error.FileNotFound => std.debug.print("fatal: could not open '{s}' for reading: No such file or directory", .{path}),
            else => std.debug.print("fatal: could not open '{s}' for reading: {}", .{ path, err }),
        }
        return err;
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

    const target_path = try getObjectPath(hash);
    const dir = target_path[0..17];
    cwd.makeDir(dir) catch |err| {
        switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        }
    };

    const target_file = try cwd.createFile(&target_path, .{ .truncate = true });
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

    return hash;
}

fn getObjectPath(hash: [20]u8) ![16 + 40]u8 {
    var buf: [16 + 40]u8 = undefined;

    _ = try std.fmt.bufPrint(&buf, "./.git/objects/{s}/{s}", .{
        std.fmt.fmtSliceHexLower(hash[0..1]),
        std.fmt.fmtSliceHexLower(hash[1..]),
    });

    return buf;
}
