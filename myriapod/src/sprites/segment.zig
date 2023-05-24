const std = @import("std");
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;
const Prng = std.rand.DefaultPrng;

// TODO: make this a template
pub fn rand_range(prng: *Prng, low: i32, high: i32) i32 {
    var range: i32 = prng.random().int(i32);
    var result = @mod(range, high + 1 - low) + low;
    return result;
}

pub fn choice(prng: *Prng, items: []const i32) i32 {
    var range: usize = prng.random().int(usize);
    var index = @mod(range, items.len);
    return items[index];
}

const DIRECTION_UP = 0;
const DIRECTION_RIGHT = 1;
const DIRECTION_DOWN = 2;
const DIRECTION_LEFT = 3;

fn inverse_direction(dir: i32) i32 {
    switch (dir) {
        .DIRECTION_UP => return DIRECTION_DOWN,
        .DIRECTION_DOWN => return DIRECTION_UP,
        .DIRECTION_LEFT => return DIRECTION_RIGHT,
        .DIRECTION_RIGHT => return DIRECTION_LEFT,
    }
}

fn is_horizontal(dir: i32) bool {
    return dir == DIRECTION_LEFT or dir == DIRECTION_RIGHT;
}

var DX = [_]i32{ 0, 1, 0, -1 };
var DY = [_]i32{ -1, 0, 1, 0 };

pub const Segment = struct {
    const Self = Segment;
    cell_x: i32,
    cell_y: i32,

    health: i32,
    fast: bool,

    head: bool, // Should this segment use the head sprite?
    in_edge: i32 = DIRECTION_LEFT,
    out_edge: i32 = DIRECTION_RIGHT,

    disallow_direction: i32 = DIRECTION_UP, // Prevents segment from moving in a particular direction
    previous_x_direction: i32 = 1, // Used to create winding/snaking motion

    frames: zgame.Canvas.List,
    anim_idx: usize = 0,
    anim_timer: usize = 0,
    prng: Prng,
    e_type: usize = 0,

    pub fn init(zg: *ZigGame, cx: i32, cy: i32, health: i32, fast: bool, head: bool) !Segment {
        var frames = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.segment_list(&frames, zg.renderer);

        const seed = @truncate(u64, @bitCast(u128, std.time.nanoTimestamp()));
        var prng = std.rand.DefaultPrng.init(seed);

        var s: Segment = .{
            .frames = frames,
            .width = frames.items[0].width,
            .height = frames.items[0].height,
            .prng = prng,
            .cx = cx,
            .cy = cy,
            .health = health,
            .fast = fast,
            .head = head,
        };

        return s;
    }

    pub fn destroy(self: *Self) void {
        _ = self;
        //self.canvas.texture.destroy();
    }

    pub fn update(self: *Self) void {

        // Move
        self.x += self.dx * self.moving_x * (3 - @floatToInt(i32, @fabs(@intToFloat(f32, self.dy))));
        self.y += self.dy * (3 - @floatToInt(i32, @fabs(@intToFloat(f32, self.dx * self.moving_x))));

        if (self.y < 592 or self.y > 784) {
            // Gone too high or low - reverse y direction
            self.moving_x = rand_range(&self.prng, 0, 1);
            self.dy = -self.dy;
        }

        self.anim_timer = (self.anim_timer + 1) % 4;
        if (0 == self.anim_timer) {
            self.anim_idx = (self.anim_idx + 1) % 4;
        }
    }

    pub fn draw(self: Self, zg: *ZigGame) void {
        var frames = [_]usize{ 0, 2, 1, 2 };
        var c = self.frames.items[frames[self.anim_idx] + self.e_type];
        var w = c.width;
        var h = c.height;
        c.blit_at(zg.renderer, self.x - (w >> 1), self.y - (h >> 1));
    }
};
