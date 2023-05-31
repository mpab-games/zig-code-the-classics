const std = @import("std");
const zgame = @import("zgame");
const zgu = zgame.util;
const ZigGame = zgame.ZigGame; // context
const zgzero = @import("zgzero/zgzero.zig");
const images = zgzero.images;
const PressSpaceSprite = @import("sprites/press_space.zig").PressSpace;

pub const NUM_GRID_ROWS = 25;
pub const NUM_GRID_COLS = 14;
const PRESS_START_Y = 420;

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

const grid = [NUM_GRID_ROWS][NUM_GRID_COLS]i32{};

pub const Direction = enum {
    UP, // 0
    RIGHT, // 1
    DOWN, // 2
    LEFT, // 3
};

const Occupied = struct {
    const Self = Occupied;
    const Item = struct {
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

pub const Game = struct {
    const Self = Game;

    pub const State = enum {
        MENU,
        PLAY,
        GAME_OVER,
    };
    state: State = State.GAME_OVER,

    bg_image: zgame.Canvas,
    title_image: zgame.Canvas,
    press_space: PressSpaceSprite,
    //logo: zgame.Canvas,
    time: zgzero.time.Ticker,
    occupied: Occupied,

    wave: i32 = -1,
    press_space_anim: usize = 0,

    pub fn init(zg: *ZigGame) !Game {
        var bg_image = try zgame.Canvas.loadPng(zg.renderer, images.bg0);
        var title_image = try zgame.Canvas.loadPng(zg.renderer, images.title);
        var press_space = try PressSpaceSprite.init(zg, 0, PRESS_START_Y);
        //var logo = try zgzero.canvases.zig_logo(zg.renderer);

        return .{
            .bg_image = bg_image,
            .title_image = title_image,
            .press_space = press_space,
            .time = zgzero.time.Ticker.init(),
            .occupied = .{},
        };
    }

    pub fn set_game_state(self: *Self, state: State) void {
        self.state = state;
    }
};
