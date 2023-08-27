const std = @import("std");
const dbg = std.log.debug;

const zg = @import("zgame"); // namespace
const ZigGame = zg.ZigGame; // context
const color = @import("color.zig");
const constant = @import("constant.zig");
const arcade_font = @import("assets.zig").fonts.arcade_legacy;

/// Exports the C interface for SDL
// zig-game hack...
// pub const c = @import("sdl-native");
pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
    @cInclude("SDL2/SDL_ttf.h");
});

pub fn c_sdl_ttf_panic() noreturn {
    const str = @as(?[*:0]const u8, c.TTF_GetError()) orelse "unknown error";
    dbg("{s}", .{str});
    @panic(std.mem.sliceTo(str, 0));
}

pub const Font = struct {
    zg_ctx: *ZigGame,
    color: zg.sdl.Color,
    font_ptr: *c.TTF_Font,

    pub fn destroy(self: Font) void {
        // c.TTF_CloseFont(self.font_ptr);
        c.TTF_CloseFont(self.font_ptr);
        c.TTF_Quit();
    }

    pub fn init(zg_ctx: *ZigGame) !Font {
        if (c.TTF_Init() != 0) {
            c.SDL_Log("Unable to initialize SDL2_ttf: %s", c.TTF_GetError());
            return error.SDLInitializationFailed;
        }

        var font_rw = c.SDL_RWFromConstMem(
            @as(*const anyopaque, @ptrCast(&arcade_font[0])),
            @as(c_int, @intCast(arcade_font.len)),
        ) orelse {
            c.SDL_Log("FAIL RWFromConstMem: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
        //defer std.debug.assert(c.SDL_RWclose(font_rw) == 0);

        var font_ptr = c.TTF_OpenFontRW(font_rw, 0, 8 * constant.SMALL_TEXT_SCALE) orelse {
            c.SDL_Log("Unable to load font: %s", c.TTF_GetError());
            return error.SDLInitializationFailed;
        };

        return .{
            .zg_ctx = zg_ctx,
            .color = color.default_text_color,
            .font_ptr = font_ptr,
        };
    }

    pub fn render(self: Font, text: []u8, x: i32, y: i32) !void {
        const surface_ptr = c.TTF_RenderUTF8_Solid(
            self.font_ptr,
            text.ptr,
            c.SDL_Color{
                .r = 0xFF,
                .g = 0xFF,
                .b = 0xFF,
                .a = 0xFF,
            },
        ) orelse {
            c.SDL_Log("FAIL render text: %s", c.TTF_GetError());
            return error.SDLInitializationFailed;
        };

        defer c.SDL_FreeSurface(surface_ptr);

        const texture_ptr = c.SDL_CreateTextureFromSurface(self.zg_ctx.renderer.ptr, surface_ptr) orelse {
            c.SDL_Log("FAIL create texture: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
        defer c.SDL_DestroyTexture(texture_ptr);

        var w = surface_ptr.*.w;
        var h = surface_ptr.*.h;
        var src_rect: zg.sdl.Rectangle = .{ .x = 0, .y = 0, .width = w, .height = h };
        var dest_rect: zg.sdl.Rectangle = .{ .x = x, .y = y, .width = w, .height = h };

        var texture: zg.sdl.Texture = .{ .ptr = texture_ptr };

        try self.zg_ctx.renderer.copy(texture, dest_rect, src_rect);
    }
};
