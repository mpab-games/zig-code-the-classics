const std = @import("std");
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;
const Prng = std.rand.DefaultPrng;
const gc = @import("../game_common.zig");

pub const Player = struct {
    const Self = Player;
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    canvas: zgame.Canvas,
    state: i32 = 0,

    pub fn destroy(self: *Self) void {
        self.canvas.texture.destroy();
    }

    pub fn update(self: *Self, game: *gc.Game) void {
        _ = self;
        _ = game;
    }

    pub fn draw(self: Self, zg: *ZigGame) void {
        if (self.state < 0) return; // termination state < 0
        self.canvas.blit_at(zg.renderer, self.x - (self.canvas.width >> 1), self.y - (self.canvas.height >> 1));
    }

    pub fn size_rect(self: Self) sdl.Rectangle {
        return sdl.Rectangle{
            .x = 0,
            .y = 0,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn position_rect(self: Self) sdl.Rectangle {
        return sdl.Rectangle{
            .x = self.x - (self.width >> 1),
            .y = self.y - (self.height >> 1),
            .width = self.width,
            .height = self.height,
        };
    }
};
