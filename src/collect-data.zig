const rl = @import("raylib");
const rlmath = @import("raylib-math");
const std = @import("std");
const FixedSizedQueue = @import("ds.zig").FixedSizedQueue;
const File = std.fs.File;
const Allocator = std.mem.Allocator;

const screenWidth = 450;
const screenHeight = 450;
const screenCenter = rl.Vector2{ .x = screenWidth / 2.0, .y = screenHeight / 2.0 };

pub fn Vector2Format(writer: anytype, point: rl.Vector2) !void {
    try std.fmt.format(writer, "[{d:.0},{d:.0}]", .{ point.x, point.y });
}

const Challenge = struct {
    const Self = @This();

    allocator: Allocator,
    file: File,
    p0: rl.Vector2,
    p1: rl.Vector2,

    pub fn init(allocator: Allocator, file: File) Self {
        var this: Self = undefined;
        this.allocator = allocator;
        this.file = file;
        return this;
    }

    pub fn reset(this: *Self, r: std.rand.Random) void {
        const angle = r.float(f32) * std.math.pi;
        const unit_direction = rl.Vector2{ .x = std.math.cos(angle), .y = std.math.sin(angle) };
        this.p0 = rlmath.Vector2Add(screenCenter, rlmath.Vector2Scale(unit_direction, 1000.0));
        this.p1 = rlmath.Vector2Add(screenCenter, rlmath.Vector2Scale(unit_direction, -1000.0));
    }

    pub fn answer(this: Self, data: []const PointInTime) !void {
        const writer = this.file.writer();
        try writer.writeAll("---\n");
        try writer.writeAll("challenge:\n");

        try writer.writeAll("- ");
        try Vector2Format(writer, this.p0);
        try writer.writeAll("\n");

        try writer.writeAll("- ");
        try Vector2Format(writer, this.p1);
        try writer.writeAll("\n");
        
        try writer.writeAll("answer:\n");
        
        for (data) |d| {
            try writer.writeAll("- {milis: ");
            try std.fmt.format(writer, "{d}", .{d.militime});
            try writer.writeAll(", point: ");
            try Vector2Format(writer, d.point);
            try writer.writeAll("}\n");
        }
        // const line_answer = try fmt("")
    }
};

var global_gpa = std.heap.GeneralPurposeAllocator(.{}){};

const PointInTime = struct {
    militime: i64,
    point: rl.Vector2,
};

pub fn main() anyerror!void {
    var queue = FixedSizedQueue(PointInTime, 256).init();

    var rng = std.rand.DefaultPrng.init(@bitCast(u64, std.time.timestamp()));

    var argv = try std.process.argsWithAllocator(global_gpa.allocator());
    defer argv.deinit();
    _ = argv.next() orelse return error.NoExecutableName;

    const file = blk: {
        const filename = argv.next() orelse {
            break :blk std.io.getStdOut();
        };
        const cwd = std.fs.cwd();
        break :blk try cwd.createFile(filename, .{.truncate=false});
    };
    var challenge = Challenge.init(global_gpa.allocator(), file);
    challenge.reset(rng.random());

    rl.InitWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.CloseWindow(); // Close window and OpenGL context

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        if (rl.IsMouseButtonReleased(rl.MouseButton.MOUSE_LEFT_BUTTON)) {
            try challenge.answer(queue.slice());
            challenge.reset(rng.random());
            queue.clear();
        }
        if (rl.IsMouseButtonDown(rl.MouseButton.MOUSE_LEFT_BUTTON)) {
            _ = queue.push(.{
                .point=rl.GetMousePosition(),
                .militime=std.time.milliTimestamp(),
            });
        }

        rl.BeginDrawing();

        rl.ClearBackground(rl.WHITE);

        rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY);
        rl.DrawLineV(challenge.p0, challenge.p1, rl.BLUE);
        var i: usize = 1;
        while (i < queue.len) : (i += 1) {
            rl.DrawLineV(queue.buffer[i - 1].point, queue.buffer[i].point, rl.BLACK);
        }

        rl.EndDrawing();
    }
}
