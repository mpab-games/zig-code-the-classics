const std = @import("std");
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;

pub const PressSpace = struct {
    const Self = PressSpace;
    x: i32 = 0,
    y: i32 = 0,

    frames: zgame.Canvas.List,
    anim_idx: usize = 0,

    pub fn init(zg: *ZigGame, x: i32, y: i32) !PressSpace {
        var frames = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.space_list(&frames, zg.renderer);
        return .{
            .x = x,
            .y = y,
            .frames = frames,
        };
    }

    pub fn destroy(self: *Self) void {
        _ = self;
        //self.canvas.texture.destroy();
    }

    pub fn update(self: *Self) void {
        self.anim_idx = (self.anim_idx + 1) % self.frames.items.len;
    }

    pub fn draw(self: Self, zg: *ZigGame) void {
        self.frames.items[self.anim_idx].blit_at(zg.renderer, self.x, self.y);
    }
};
