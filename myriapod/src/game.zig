const std = @import("std");
const zgame = @import("zgame");
const zgu = zgame.util;
const range = zgu.range;
const ZigGame = zgame.ZigGame; // context
const zgzero = @import("zgzero/zgzero.zig");
const images = zgzero.images;
const canvases = zgzero.canvases;
const PressSpaceSprite = @import("sprites/press_space.zig").PressSpace;

// all magic numbers belong in here

pub const NUM_GRID_ROWS = 25;
pub const NUM_GRID_COLS = 14;
const PRESS_START_Y = 420;

pub const SCREEN_WIDTH = 480;
pub const SCREEN_HEIGHT = 800;
pub const SCREEN_TITLE = "Myriapod";

pub const PLYR_START_X = 240;
pub const PLYR_START_Y = 768;

pub fn pos2cell(x: i32, y: i32) zgame.Point {
    return .{ .x = (x - 16) / 32, .y = y / 32 };
}

// Convert grid cell position to pixel coordinates, with a given offset
pub fn cell2posOff(cell_x: i32, cell_y: i32, x_offset: i32, y_offset: i32) zgame.Point {
    // If the requested offset is zero, returns the centre of the requested cell, hence the +16. In the case of the
    // X axis, there's a 16 pixel border at the left and right of the screen, hence +16 becomes +32.
    return .{ .x = (cell_x * 32) + 32 + x_offset, .y = cell_y * 32 + 16 + y_offset };
}

pub fn cell2pos(cell_x: i32, cell_y: i32) zgame.Point {
    return cell2posOff(cell_x, cell_y, 0, 0);
}

//pub const grid = [NUM_GRID_ROWS][NUM_GRID_COLS]i32{};

pub const Direction = enum {
    UP, // 0
    RIGHT, // 1
    DOWN, // 2
    LEFT, // 3
};

pub const Occupied = struct {
    const Self = Occupied;
    pub const Item = struct {
        x: i32,
        y: i32,
        dir: ?Direction,
    };

    const OccupiedList = std.ArrayList(Item);
    list: OccupiedList = OccupiedList.init(std.heap.page_allocator),

    pub fn add(self: *Self, item: Item) !usize {
        try self.list.append(item);
        return self.list.items.len - 1;
    }

    pub fn clear(self: *Self) void {
        self.list.clearAndFree();
    }

    pub fn in(self: *Self, item: *Item) bool {
        var idx: usize = 0;
        while (idx != self.list.items.len) : (idx += 1) {
            var s = &self.list.items[idx];
            if (s.x == item.x and s.y == item.y)
                return true;
        }
        return false;
    }
};

const DigitsImages = struct {
    const Self = DigitsImages;
    zg: *ZigGame,
    list: zgame.Canvas.List,

    pub fn init(
        zg: *ZigGame,
    ) !DigitsImages {
        var list = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.digit_list(&list, zg.renderer);

        var s: DigitsImages = .{
            .zg = zg,
            .list = list,
        };

        return s;
    }

    pub fn draw(self: Self, char: usize, x: i32, y: i32) void {
        self.list.items[char].blit_at(self.zg.renderer, x, y);
    }
};

pub const State = enum {
    MENU,
    PLAY,
    GAME_OVER,
};

// all 'game' functions - but no logic
pub const Game = struct {
    const Self = Game;
    state: State = State.GAME_OVER,

    bg_image: zgame.Canvas,
    digits_images: DigitsImages,

    title_image: zgame.Canvas,
    press_space: PressSpaceSprite,
    time: zgzero.time.Ticker,
    occupied: Occupied,
    grid: [NUM_GRID_ROWS][NUM_GRID_COLS]i32,

    wave: i32 = -1,
    press_space_anim: usize = 0,

    player_lives: i32 = 3,
    player_score: i32 = 0,
    player_life_image: zgame.Canvas,

    zg: *ZigGame,

    pub fn init(zg: *ZigGame) !Game {
        var bg_image = try zgame.Canvas.loadPng(zg.renderer, images.bg0);
        var digits_images = try DigitsImages.init(zg);
        var player_life_image = try zgame.Canvas.loadPng(zg.renderer, images.life);
        var title_image = try zgame.Canvas.loadPng(zg.renderer, images.title);
        var press_space = try PressSpaceSprite.init(zg, 0, PRESS_START_Y);
        //var logo = try zgzero.canvases.zig_logo(zg.renderer);

        return .{
            .bg_image = bg_image,
            .digits_images = digits_images,
            .player_life_image = player_life_image,
            .title_image = title_image,
            .press_space = press_space,
            .time = zgzero.time.Ticker.init(),
            .occupied = .{},
            .grid = .{},
            .zg = zg,
        };
    }

    pub fn draw_score(self: *Self) void {
        var score_str = std.fmt.allocPrint(
            std.heap.page_allocator,
            "{}",
            .{self.player_score},
        ) catch return;
        defer std.heap.page_allocator.free(score_str);

        for (range(score_str.len), 0..) |_, i| {
            var digit = score_str[score_str.len - i - 1] - '0';
            self.digits_images.draw(digit, @as(i32, @intCast(468 - i * 24)) - 24, 5);
        }
    }

    pub fn draw_lives(self: *Self) void {
        for (range(@as(usize, @intCast(self.player_lives))), 0..) |_, i| {
            self.player_life_image.blit_at(self.zg.renderer, @as(i32, @intCast(i * 40 + 8)), 4);
        }
    }
};
