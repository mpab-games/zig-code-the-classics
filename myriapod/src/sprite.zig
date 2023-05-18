const std = @import("std");
const dbg = std.log.debug;
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const ZgSprite = Sprite;
const zgzero = @import("zgzero/zgzero.zig");
const images = zgzero.images;
const FlyingEnemy = @import("sprites/flying_enemy.zig").FlyingEnemy;

// Facade pattern
pub const Sprite = union(enum) { // Facade
    pub const Data = struct { // 'common' data - Adapter
        x: i32 = 0,
        y: i32 = 0,
        width: i32 = 0,
        height: i32 = 0,
        dx: i32 = 0, // TODO: use polar vector
        dy: i32 = 0,
        vel: i32 = 0,
        state: i32 = 0,
    };

    player: Player,
    flying_enemy: FlyingEnemy,
    rock: Rock,
    bullet: Bullet,
    segment: Segment,

    pub fn destroy(self: *Sprite) void {
        switch (self.*) {
            .player => |*s| s.destroy(),
            .flying_enemy => |*s| s.destroy(),
            .rock => |*s| s.destroy(),
            .bullet => |*s| s.destroy(),
            .segment => |*s| s.destroy(),
        }
    }

    pub fn get(self: Sprite) Data {
        var d: Data = .{};
        switch (self) {
            .player => |s| {
                d.x = s.x;
                d.y = s.y;
                d.width = s.width;
                d.height = s.height;
                d.state = s.state;
            },
            .flying_enemy => |s| {
                d.x = s.x;
                d.y = s.y;
                d.width = s.width;
                d.height = s.height;
                d.state = s.state;
            },
            .rock => |s| {
                d.x = s.x;
                d.y = s.y;
                d.width = s.width;
                d.height = s.height;
                d.state = s.state;
            },
            .bullet => |s| {
                d.x = s.x;
                d.y = s.y;
                d.width = s.width;
                d.height = s.height;
                d.state = s.state;
            },
            .segment => |s| {
                d.x = s.x;
                d.y = s.y;
                d.width = s.width;
                d.height = s.height;
                d.state = s.state;
            },
        }
        return d;
    }

    pub fn set(self: *Sprite, d: Data) void {
        switch (self.*) {
            .player => |*s| {
                s.x = d.x;
                s.y = d.y;
                s.width = d.width;
                s.height = d.height;
                s.state = d.state;
            },
            .flying_enemy => |*s| {
                s.x = d.x;
                s.y = d.y;
                s.width = d.width;
                s.height = d.height;
                s.state = d.state;
            },
            .rock => |*s| {
                s.x = d.x;
                s.y = d.y;
                s.width = d.width;
                s.height = d.height;
                s.state = d.state;
            },
            .bullet => |*s| {
                s.x = d.x;
                s.y = d.y;
                s.width = d.width;
                s.height = d.height;
                s.state = d.state;
            },
            .segment => |*s| {
                s.x = d.x;
                s.y = d.y;
                s.width = d.width;
                s.height = d.height;
                s.state = d.state;
            },
        }
    }

    pub fn canvas(self: Sprite) zgame.Canvas {
        switch (self) {
            .player => |s| return s.canvas,
            .flying_enemy => |s| return s.canvas,
            .rock => |s| return s.canvas,
            .bullet => |s| return s.canvas,
            .segment => |s| return s.canvas,
        }
    }

    pub fn update(self: *Sprite) void {
        switch (self.*) {
            .player => |*s| s.update(),
            .flying_enemy => |*s| s.update(),
            .rock => |*s| s.update(),
            .bullet => |*s| s.update(),
            .segment => |*s| s.update(),
        }
    }

    pub fn draw(self: Sprite, zg: *ZigGame) void {
        switch (self) {
            .player => |s| s.draw(zg),
            .flying_enemy => |s| s.draw(zg),
            .rock => |s| s.draw(zg),
            .bullet => |s| s.draw(zg),
            .segment => |s| s.draw(zg),
        }
    }

    pub fn size_rect(self: Sprite) sdl.Rectangle {
        switch (self) {
            .player => |s| return s.size_rect(),
            .flying_enemy => |s| return s.size_rect(),
            .rock => |s| return s.size_rect(),
            .bullet => |s| return s.size_rect(),
            .segment => |s| return s.size_rect(),
        }
    }

    pub fn position_rect(self: Sprite) sdl.Rectangle {
        switch (self) {
            .player => |s| return s.position_rect(),
            .flying_enemy => |s| return s.position_rect(),
            .rock => |s| return s.position_rect(),
            .bullet => |s| return s.position_rect(),
            .segment => |s| return s.position_rect(),
        }
    }
};

const Player = struct {
    const Self = Player;
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    canvas: zgame.Canvas,
    state: i32 = 0,

    fn destroy(self: *Self) void {
        self.canvas.texture.destroy();
    }

    fn update(self: *Self) void {
        _ = self;
    }

    fn draw(self: Self, zg: *ZigGame) void {
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

// const FlyingEnemy = struct {
//     const Self = FlyingEnemy;
//     x: i32,
//     y: i32,
//     width: i32,
//     height: i32,
//     canvas: zgame.Canvas,
//     state: i32 = 0,

//     fn destroy(self: *Self) void {
//         self.canvas.texture.destroy();
//     }

//     fn update(self: *Self) void {
//         _ = self;
//     }

//     fn draw(self: Self, zg: *ZigGame) void {
//         if (self.state < 0) return; // termination state < 0
//         self.canvas.blit_at(zg.renderer, self.x - (self.canvas.width >> 1), self.y - (self.canvas.height >> 1));
//     }

//     pub fn size_rect(self: Self) sdl.Rectangle {
//         return sdl.Rectangle{
//             .x = 0,
//             .y = 0,
//             .width = self.width,
//             .height = self.height,
//         };
//     }

//     pub fn position_rect(self: Self) sdl.Rectangle {
//         return sdl.Rectangle{
//             .x = self.x,
//             .y = self.y,
//             .width = self.width,
//             .height = self.height,
//         };
//     }
// };

const Rock = struct {
    const Self = Rock;
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    canvas: zgame.Canvas,
    state: i32 = 0,

    fn destroy(self: *Self) void {
        self.canvas.texture.destroy();
    }

    fn update(self: *Self) void {
        _ = self;
    }

    fn draw(self: Self, zg: *ZigGame) void {
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
            .x = self.x,
            .y = self.y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Bullet = struct {
    const Self = Bullet;
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    canvas: zgame.Canvas,
    state: i32 = 0,
    dy: i32,

    fn destroy(self: *Self) void {
        self.canvas.texture.destroy();
    }

    fn update(self: *Self) void {
        self.y += self.dy;
    }

    fn draw(self: Self, zg: *ZigGame) void {
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

const Segment = struct {
    const Self = Segment;
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    canvas: zgame.Canvas,
    state: i32 = 0,

    fn destroy(self: *Self) void {
        self.canvas.texture.destroy();
    }

    fn update(self: *Self) void {
        _ = self;
    }

    fn draw(self: Self, zg: *ZigGame) void {
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
            .x = self.x,
            .y = self.y,
            .width = self.width,
            .height = self.height,
        };
    }
};

pub const Factory = struct {
    const Self = Factory;
    pub const Type = ZgSprite;
    zg: *ZigGame,

    pub fn init(zg: *ZigGame) Factory {
        return .{
            .zg = zg,
        };
    }

    pub const player = struct {
        pub fn new(self: Self, x: i32, y: i32) !ZgSprite {
            var canvas = try zgame.Canvas.loadPng(self.zg.renderer, images.player00);
            return .{ .player = .{
                .x = x,
                .y = y,
                .width = canvas.width,
                .height = canvas.height,
                .canvas = canvas,
            } };
        }
    };

    pub const flying_enemy = struct {
        pub fn new(self: Self, player_x: i32) !ZgSprite {
            var fe = try FlyingEnemy.init(self.zg, player_x);
            return .{ .flying_enemy = fe };
        }
    };

    pub const rock = struct {
        pub fn new(canvas: zgame.Canvas, x: i32, y: i32, vel: i32, dx: i32, dy: i32) ZgSprite {
            return .{ .rock = .{
                .x = x,
                .y = y,
                .vel = vel,
                .dx = dx,
                .dy = dy,
                .width = canvas.width,
                .height = canvas.height,
                .canvas = canvas,
            } };
        }
    };

    pub const bullet = struct {
        pub fn new(self: Self, x: i32, y: i32, dy: i32) !ZgSprite {
            var canvas = try zgame.Canvas.loadPng(self.zg.renderer, images.bullet);
            return .{ .bullet = .{ .x = x, .y = y, .width = canvas.width, .height = canvas.height, .canvas = canvas, .dy = dy } };
        }
    };

    pub const segment = struct {
        pub fn new(canvas: zgame.Canvas, x: i32, y: i32, vel: i32, dx: i32, dy: i32) ZgSprite {
            return .{ .segment = .{
                .x = x,
                .y = y,
                .vel = vel,
                .dx = dx,
                .dy = dy,
                .width = canvas.width,
                .height = canvas.height,
                .canvas = canvas,
            } };
        }
    };
};
