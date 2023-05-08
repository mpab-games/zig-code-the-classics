const std = @import("std");
pub const sdl = @import("sdl-wrapper"); // configured in build.zig
pub const sprite = @import("sprite.zig");

pub const Canvas = struct {
    pub const List = std.ArrayList(Canvas);
    width: i32,
    height: i32,
    texture: sdl.Texture,

    pub fn init(tex: sdl.Texture, width: i32, height: i32) Canvas {
        return .{ .texture = tex, .width = width, .height = height };
    }

    pub fn loadPng(renderer: sdl.Renderer, file: [:0]const u8) !Canvas {
        var texture = try sdl.image.loadTextureMem(
            renderer,
            file,
            sdl.image.ImgFormat.png,
        );
        var inf = try texture.query();
        var width = @intCast(i32, inf.width);
        var height = @intCast(i32, inf.height);
        return Canvas.init(texture, width, height);
    }

    pub fn blit(self: Canvas, renderer: sdl.Renderer) void {
        renderer.copy(self.texture, null, null) catch return;
    }

    pub fn blit_at(self: Canvas, renderer: sdl.Renderer, x: i32, y: i32) void {
        var size = self.size_rect();
        var pos = size;
        pos.x = x;
        pos.y = y;
        self.blit_rect(renderer, pos, size);
    }

    pub fn blit_rect(self: Canvas, renderer: sdl.Renderer, pos_rect: sdl.Rectangle, sz_rect: sdl.Rectangle) void {
        renderer.copy(self.texture, pos_rect, sz_rect) catch return;
    }

    pub fn size_rect(self: Canvas) sdl.Rectangle {
        return sdl.Rectangle{
            .x = 0,
            .y = 0,
            .width = self.width,
            .height = self.height,
        };
    }
};

pub const Point = struct { x: i32, y: i32 };

pub const Rect = struct {
    left: i32,
    top: i32,
    right: i32,
    bottom: i32,

    pub fn from_sdl_rect(r: sdl.Rectangle) Rect {
        return .{ .left = r.x, .top = r.y, .right = r.x + r.width, .bottom = r.y + r.height };
    }
};

pub const FontInfo = struct {
    width: u8,
    height: u8,
    data: [128]u64,
};

pub const TextDrawInfo = struct {
    fg: sdl.Color,
    bg: sdl.Color,
    scaling: u8,
    renderer: sdl.Renderer,
};
