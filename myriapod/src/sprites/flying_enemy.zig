const std = @import("std");
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;
const Prng = std.rand.DefaultPrng;
const GAME = @import("../game.zig");

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

pub const FlyingEnemy = struct {
    const Self = FlyingEnemy;
    x: i32 = 0,
    y: i32 = 0,
    dx: i32 = 0,
    dy: i32 = 0,
    width: i32,
    height: i32,
    state: i32 = 0,
    moving_x: i32 = 1,
    health: i32 = 0,

    frames: zgame.Canvas.List,
    anim_idx: usize = 0,
    prng: Prng,
    e_type: usize = 0,

    pub fn init(zg: *ZigGame, player_x: i32) !FlyingEnemy {
        var frames = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.meanie_list(&frames, zg.renderer);

        const seed = @truncate(u64, @bitCast(u128, std.time.nanoTimestamp()));
        var prng = std.rand.DefaultPrng.init(seed);

        var fe: FlyingEnemy = .{
            .frames = frames,
            .width = frames.items[0].width,
            .height = frames.items[0].height,
            .prng = prng,
        };

        fe.reset(player_x);

        return fe;
    }

    pub fn destroy(self: *Self) void {
        _ = self;
        //self.canvas.texture.destroy();
    }

    pub fn reset(self: *Self, player_x: i32) void {
        var side: i32 = rand_range(&self.prng, 0, 1);
        if (player_x < 160)
            side = 1;
        if (player_x > 320)
            side = 0;

        var x: i32 = 550 * side - 35;
        var y: i32 = 688;

        var dx: i32 = 1 - 2 * side; //  # Move left or right depending on which side of the screen we're on
        var ud = [_]i32{ -1, 1 };
        var dy: i32 = choice(&self.prng, &ud); // Start moving either up or down

        var e_type = @intCast(usize, rand_range(&self.prng, 0, 2) * 3);

        self.x = x;
        self.y = y;
        self.dx = dx;
        self.dy = dy;
        self.e_type = e_type;

        self.health = 1;
    }

    pub fn update(self: *Self, game: *GAME.Game) void {

        // Move
        self.x += self.dx * self.moving_x * (3 - @floatToInt(i32, @fabs(@intToFloat(f32, self.dy))));
        self.y += self.dy * (3 - @floatToInt(i32, @fabs(@intToFloat(f32, self.dx * self.moving_x))));

        if (self.y < 592 or self.y > 784) {
            // Gone too high or low - reverse y direction
            self.moving_x = rand_range(&self.prng, 0, 1);
            self.dy = -self.dy;
        }

        if (0 == game.time.count % 4) {
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
