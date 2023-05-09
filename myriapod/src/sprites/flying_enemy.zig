const std = @import("std");
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;

pub const FlyingEnemy = struct {
    const Self = FlyingEnemy;
    x: i32 = 0,
    y: i32 = 0,
    dx: i32 = 0,
    dy: i32 = 0,
    width: i32,
    height: i32,
    state: i32 = 0,

    frames: zgame.Canvas.List,
    anim_idx: usize = 0,

    pub fn init(zg: *ZigGame, x: i32, y: i32) !FlyingEnemy {
        var frames = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.meanie_list(&frames, zg.renderer);
        return .{
            .x = x,
            .y = y,
            .frames = frames,
            .width = frames.items[0].width,
            .height = frames.items[0].height,
        };
    }

    pub fn destroy(self: *Self) void {
        _ = self;
        //self.canvas.texture.destroy();
    }

    pub fn update(self: *Self) void {

        // Move
        // self.x += self.dx * self.moving_x * (3 - abs(self.dy))
        // self.y += self.dy * (3 - abs(self.dx * self.moving_x))

        // if (self.y < 592 or self.y > 784){
        //     // Gone too high or low - reverse y direction
        //     self.moving_x = randint(0, 1)
        //     self.dy = -self.dy
        // }

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
