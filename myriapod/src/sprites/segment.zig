const std = @import("std");
const dbg = std.log.debug;
const zgame = @import("zgame"); // namespace
const zgu = zgame.util; // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;
const gc = @import("../game_common.zig");

fn to_sz(dir: gc.Direction) usize {
    switch (dir) {
        .UP => return 0,
        .RIGHT => return 1,
        .DOWN => return 2,
        .LEFT => return 3,
    }
}

fn to_i32(dir: gc.Direction) i32 {
    switch (dir) {
        .UP => return 0,
        .RIGHT => return 1,
        .DOWN => return 2,
        .LEFT => return 3,
    }
}

fn inverse_direction(dir: gc.Direction) gc.Direction {
    switch (dir) {
        .UP => return gc.Direction.DOWN,
        .DOWN => return gc.Direction.UP,
        .LEFT => return gc.Direction.RIGHT,
        .RIGHT => return gc.Direction.LEFT,
    }
}

fn is_horizontal(dir: gc.Direction) bool {
    return dir == gc.Direction.LEFT or dir == gc.Direction.RIGHT;
}

const DX = [_]i32{ 0, 1, 0, -1 };
const DY = [_]i32{ -1, 0, 1, 0 };

const SECONDARY_AXIS_SPEED = [_]i32{ 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2 };
const SECONDARY_AXIS_POSITIONS = [_]i32{ 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14 };

const ROTATION_MATRICES = [4][4]i32{
    [_]i32{ 1, 0, 0, 1 },
    [_]i32{ 0, -1, 1, 0 },
    [_]i32{ -1, 0, 0, -1 },
    [_]i32{ 0, 1, -1, 0 },
};

const rank_fn = fn (*Segment, i32) i32;

const Ranking = struct {
    out: bool,
    turning_back_on_self: bool,
    direction_disallowed: bool,
    occupied_by_segmen: bool,
    rock_present: bool,
    horizontal_blocked: bool,
    same_as_previous_x_direction: bool,
};

fn ranker(seg: *Segment, game: *gc.Game, proposed_out_edge: gc.Direction) Ranking {
    var new_cell_x = seg.cell_x + DX[proposed_out_edge];
    var new_cell_y = seg.cell_y + DY[proposed_out_edge];

    var out = new_cell_x < 0 or new_cell_x > (gc.num_grid_cols - 1) or (new_cell_y < 0) or new_cell_y > (gc.num_grid_rows - 1);

    var turning_back_on_self = proposed_out_edge == seg.in_edge;

    var direction_disallowed = proposed_out_edge == seg.disallow_direction;

    var rock: i32 = undefined;

    if (out or (new_cell_y == 0 and new_cell_x < 0)) {
        rock = 0;
    } else {
        rock = gc.grid[new_cell_y][new_cell_x];
    }

    var rock_present: bool = rock != 0;
    var o1: gc.Occupied.Item = .{ .x = new_cell_x, .y = new_cell_y };
    var o2: gc.Occupied.Item = .{ .x = new_cell_x, .y = new_cell_y, .dir = proposed_out_edge };

    var occupied_by_segment = game.occupied.in(&o1) or game.occupied.in(&o2);

    var horizontal_blocked: bool = undefined;

    if (rock_present) {
        horizontal_blocked = is_horizontal(proposed_out_edge);
    } else {
        horizontal_blocked = !is_horizontal(proposed_out_edge);
    }

    var same_as_previous_x_direction = proposed_out_edge == seg.previous_x_direction;

    return .{
        .out = out,
        .turning_back_on_self = turning_back_on_self,
        .direction_disallowed = direction_disallowed,
        .occupied_by_segment = occupied_by_segment,
        .rock_present = rock_present,
        .horizontal_blocked = horizontal_blocked,
        .same_as_previous_x_direction = same_as_previous_x_direction,
    };
}

pub const Segment = struct {
    const Self = Segment;
    x: i32 = 0,
    y: i32 = 0,
    cell_x: i32,
    cell_y: i32,

    health: i32,
    fast: bool,

    head: bool, // Should this segment use the head sprite?
    in_edge: gc.Direction = gc.Direction.LEFT,
    out_edge: gc.Direction = gc.Direction.RIGHT,

    disallow_direction: gc.Direction = gc.Direction.UP, // Prevents segment from moving in a particular direction
    previous_x_direction: usize = 1, // Used to create winding/snaking motion

    frames: zgame.Canvas.List,
    anim_idx: usize = 0,

    pub fn init(zg: *ZigGame, cell_x: i32, cell_y: i32, health: i32, fast: bool, head: bool) !Segment {
        var frames = zgame.Canvas.List.init(std.heap.page_allocator);
        try canvases.seg_list(&frames, zg.renderer);

        var s: Segment = .{
            .frames = frames,
            .cell_x = cell_x,
            .cell_y = cell_y,
            .health = health,
            .fast = fast,
            .head = head,
        };

        return s;
    }

    pub fn destroy(self: *Self) void {
        _ = self;
        //self.canvas.texture.destroy();
    }

    pub fn update(self: *Self, game: *gc.Game) void {
        var phase: usize = game.time.count % 16;
        var out_edge_sz: usize = @enumToInt(self.out_edge);

        if (phase == 0) {
            self.cell_x += DX[out_edge_sz];
            self.cell_y += DY[out_edge_sz];

            self.in_edge = inverse_direction(self.out_edge);

            if (self.cell_y == 18) // TODO: handle attract screen where the y limit is 0
                self.disallow_direction = gc.Direction.UP;
            if (self.cell_y == gc.NUM_GRID_ROWS - 1)
                self.disallow_direction = gc.Direction.DOWN;
        } else if (phase == 4) {
            // TODO: fix this
            //var key = ranker(self, game, 0);
            //self.out_edge = std.min(zgu.range(4), key);

            if (is_horizontal(self.out_edge))
                self.previous_x_direction = out_edge_sz;

            var new_cell_x = self.cell_x + DX[out_edge_sz];
            var new_cell_y = self.cell_y + DY[out_edge_sz];

            // if (new_cell_x >= 0 and new_cell_x < gc.num_grid_cols)
            //     game.damage(new_cell_x, new_cell_y, 5);

            _ = game.occupied.add(.{ .x = new_cell_x, .y = new_cell_y, .dir = null }) catch return;
            _ = game.occupied.add(.{ .x = new_cell_x, .y = new_cell_y, .dir = inverse_direction(self.out_edge) }) catch return;
        }

        var turn_idx: i32 = @mod(to_i32(self.out_edge) - to_i32(self.in_edge), 4);
        var turn_i32: i32 = @intCast(i32, turn_idx);

        var offset_x: i32 = SECONDARY_AXIS_POSITIONS[phase] * (2 - turn_i32);
        var stolen_y_movement: i32 = SECONDARY_AXIS_POSITIONS[phase] * @mod(turn_i32, 2);
        var offset_y: i32 = -16 + (@intCast(i32, phase * 2)) - stolen_y_movement;

        var rotation_matrix = ROTATION_MATRICES[to_sz(self.in_edge)];
        offset_x = offset_x * rotation_matrix[0] + offset_y * rotation_matrix[1];
        offset_y = offset_x * rotation_matrix[2] + offset_y * rotation_matrix[3];

        // TODO: fix offset_y
        offset_y = 0;

        var pos = gc.cell2posOff(self.cell_x, self.cell_y, offset_x, offset_y);
        self.x = pos.x;
        self.y = pos.y;

        var direction: i32 = @mod(SECONDARY_AXIS_SPEED[phase] * (turn_idx - 2) + to_i32(self.in_edge) * 2 + 4, 8);
        var leg_frame: usize = @divTrunc(phase, 4); // 16 phase cycle, 4 frames of animation

        var x128: usize = @boolToInt(self.fast);
        var x64: usize = @boolToInt(self.health == 2);
        var x32: usize = @boolToInt(self.head);

        self.anim_idx = x128 * 128 + x64 * 64 + x32 * 32 + @intCast(usize, direction) * 4 + leg_frame;

        // var img_str = std.fmt.allocPrint(
        //     std.heap.page_allocator,
        //     "seg{}{}{}{}{}",
        //     .{ x128, x64, x32, direction, leg_frame },
        // ) catch return;
        // defer std.heap.page_allocator.free(img_str);

        // dbg("{s}", .{img_str});
    }

    pub fn draw(self: Self, zg: *ZigGame) void {
        var c = self.frames.items[self.anim_idx];
        var w = c.width;
        var h = c.height;
        c.blit_at(zg.renderer, self.x - (w >> 1), self.y - (h >> 1));
    }
};
