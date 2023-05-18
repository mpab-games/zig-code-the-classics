const std = @import("std");
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;
const Prng = std.rand.DefaultPrng;

pub fn choice(prng: *Prng, low: i32, high: i32) i32 {
    // rand() % (high + 1 - low) + low
    var range: i32 = prng.random().int(i32);
    var result = @mod(range, high + 1 - low) + low;
    return result;
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

    frames: zgame.Canvas.List,
    anim_idx: usize = 0,
    prng: Prng,

    pub fn init(zg: *ZigGame, player_x: i32) !FlyingEnemy {
        _ = player_x;
        var frames = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.meanie_list(&frames, zg.renderer);

        const seed = @truncate(u64, @bitCast(u128, std.time.nanoTimestamp()));
        var prng = std.rand.DefaultPrng.init(seed);

        // 0 - lhs; 1 - rhs
        var side: i32 = 1; //choice(&prng, 0, 1);
        // if (player_x < 160)
        //     side = 1;
        // if (player_x > 320)
        //     side = 0;

        var x: i32 = 550 * side - 35;
        var y: i32 = 688;

        var dx: i32 = 1 - 2 * side; //  # Move left or right depending on which side of the screen we're on
        var dy: i32 = choice(&prng, -1, 1); // Start moving either up or down

        //self.type = randint(0, 2)   # 3 different colours
        //self.rnd.range();

        return .{
            .x = x,
            .y = y,
            .dx = dx,
            .dy = dy,
            .frames = frames,
            .width = frames.items[0].width,
            .height = frames.items[0].height,
            .prng = prng,
        };
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
            self.moving_x = choice(&self.prng, 0, 1);
            self.dy = -self.dy;
        }

        //anim_frame = str([0, 2, 1, 2][(self.timer // 4) % 4])
        //self.image = "meanie" + str(self.type) + anim_frame

        self.anim_idx = (self.anim_idx + 1) % 3;
    }

    pub fn draw(self: Self, zg: *ZigGame) void {
        var c = self.frames.items[self.anim_idx + 6];
        var w = c.width;
        var h = c.height;
        c.blit_at(zg.renderer, self.x - (w >> 1), self.y - (h >> 1));
    }
};
