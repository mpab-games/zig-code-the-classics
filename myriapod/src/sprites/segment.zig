const std = @import("std");
const dbg = std.log.debug;
const zgame = @import("zgame"); // namespace
const zgu = zgame.util; // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = @import("zgame").sdl;
const zgzero = @import("../zgzero/zgzero.zig");
const canvases = zgzero.canvases;
const GAME = @import("../game.zig");

fn to_sz(dir: GAME.Direction) usize {
    switch (dir) {
        .UP => return 0,
        .RIGHT => return 1,
        .DOWN => return 2,
        .LEFT => return 3,
    }
}

fn to_i32(dir: GAME.Direction) i32 {
    switch (dir) {
        .UP => return 0,
        .RIGHT => return 1,
        .DOWN => return 2,
        .LEFT => return 3,
    }
}

fn inverse_direction(dir: GAME.Direction) GAME.Direction {
    switch (dir) {
        .UP => return GAME.Direction.DOWN,
        .DOWN => return GAME.Direction.UP,
        .LEFT => return GAME.Direction.RIGHT,
        .RIGHT => return GAME.Direction.LEFT,
    }
}

fn is_horizontal(dir: GAME.Direction) bool {
    return dir == GAME.Direction.LEFT or dir == GAME.Direction.RIGHT;
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

const Ranking = packed struct {
    same_as_previous_x_direction: u1,
    horizontal_blocked: u1,
    rock_present: u1,
    occupied_by_segment: u1,
    direction_disallowed: u1,
    turning_back_on_self: u1,
    out: u1,
};

// TODO: unkludge
fn rank_dirs(dirs: [4]GAME.Direction, ranks: [4]Ranking) GAME.Direction {
    var _0 = @as(u7, @bitCast(ranks[0]));
    var _1 = @as(u7, @bitCast(ranks[1]));
    var _2 = @as(u7, @bitCast(ranks[2]));
    var _3 = @as(u7, @bitCast(ranks[3]));
    var idx: usize = 1;

    if (_0 <= _1 and _0 <= _2 and _0 <= _3)
        idx = 0;
    // if (_1 <= _0 and _1 <= _2 and _1 <= _3)
    //     idx = 1;
    if (_2 <= _1 and _2 <= _0 and _2 <= _3)
        idx = 2;
    if (_3 <= _1 and _3 <= _2 and _3 <= _0)
        idx = 3;

    //dbg("rank_dirs: {}-{}-{}-{}=>{}", .{ _0, _1, _2, _3, idx });

    return dirs[idx];
}

fn ranker(seg: *Segment, game: *GAME.Game, proposed_out_edge: GAME.Direction) Ranking {
    var new_cell_x = seg.cell_x + DX[to_sz(proposed_out_edge)];
    var new_cell_y = seg.cell_y + DY[to_sz(proposed_out_edge)];

    var out = new_cell_x < 0 or new_cell_x > (GAME.NUM_GRID_COLS - 1) or (new_cell_y < 0) or new_cell_y > (GAME.NUM_GRID_ROWS - 1);

    var turning_back_on_self = proposed_out_edge == seg.in_edge;

    var direction_disallowed = proposed_out_edge == seg.disallow_direction;

    var rock: i32 = undefined;

    if (out or (new_cell_y == 0 and new_cell_x < 0)) {
        rock = 0;
    } else {
        rock = game.grid[@as(usize, @intCast(new_cell_y))][@as(usize, @intCast(new_cell_x))];
    }

    var rock_present: bool = rock != 0;
    var o1: GAME.Occupied.Item = .{ .x = new_cell_x, .y = new_cell_y, .dir = null };
    var o2: GAME.Occupied.Item = .{ .x = new_cell_x, .y = new_cell_y, .dir = proposed_out_edge };

    var occupied_by_segment = game.occupied.in(&o1) or game.occupied.in(&o2);

    var horizontal_blocked: bool = undefined;

    if (rock_present) {
        horizontal_blocked = is_horizontal(proposed_out_edge);
    } else {
        horizontal_blocked = !is_horizontal(proposed_out_edge);
    }

    var same_as_previous_x_direction = proposed_out_edge == seg.previous_x_direction;

    return .{
        .out = @intFromBool(out),
        .turning_back_on_self = @intFromBool(turning_back_on_self),
        .direction_disallowed = @intFromBool(direction_disallowed),
        .occupied_by_segment = @intFromBool(occupied_by_segment),
        .rock_present = @intFromBool(rock_present),
        .horizontal_blocked = @intFromBool(horizontal_blocked),
        .same_as_previous_x_direction = @intFromBool(same_as_previous_x_direction),
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
    in_edge: GAME.Direction = GAME.Direction.LEFT,
    out_edge: GAME.Direction = GAME.Direction.RIGHT,

    disallow_direction: GAME.Direction = GAME.Direction.UP, // Prevents segment from moving in a particular direction
    previous_x_direction: GAME.Direction = GAME.Direction.RIGHT, // Used to create winding/snaking motion

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

    pub fn update(self: *Self, game: *GAME.Game) void {
        var phase: usize = game.time.count % 16;
        var out_edge_sz: usize = @intFromEnum(self.out_edge);

        if (phase == 0) {
            self.cell_x += DX[out_edge_sz];
            self.cell_y += DY[out_edge_sz];

            self.in_edge = inverse_direction(self.out_edge);

            // handle attract screen where the y limit is 0
            var ylimit: i32 = if (game.state == GAME.State.MENU) 0 else 18;
            if (self.cell_y == ylimit)
                self.disallow_direction = GAME.Direction.UP;
            if (self.cell_y == GAME.NUM_GRID_ROWS - 1)
                self.disallow_direction = GAME.Direction.DOWN;
        } else if (phase == 4) {
            // TODO: fix this
            var dirs = [_]GAME.Direction{ GAME.Direction.UP, GAME.Direction.RIGHT, GAME.Direction.DOWN, GAME.Direction.LEFT };

            var ranks = [_]Ranking{
                ranker(self, game, GAME.Direction.UP),
                ranker(self, game, GAME.Direction.RIGHT),
                ranker(self, game, GAME.Direction.DOWN),
                ranker(self, game, GAME.Direction.LEFT),
            };

            self.out_edge = rank_dirs(dirs, ranks);
            out_edge_sz = @intFromEnum(self.out_edge);

            if (is_horizontal(self.out_edge))
                self.previous_x_direction = self.out_edge;

            var new_cell_x = self.cell_x + DX[out_edge_sz];
            var new_cell_y = self.cell_y + DY[out_edge_sz];

            // if (new_cell_x >= 0 and new_cell_x < GAME.num_grid_cols)
            //     game.damage(new_cell_x, new_cell_y, 5);

            _ = game.occupied.add(.{ .x = new_cell_x, .y = new_cell_y, .dir = null }) catch return;
            _ = game.occupied.add(.{ .x = new_cell_x, .y = new_cell_y, .dir = inverse_direction(self.out_edge) }) catch return;
        }

        var turn_idx: i32 = @mod(to_i32(self.out_edge) - to_i32(self.in_edge), 4);
        var turn_i32: i32 = @as(i32, @intCast(turn_idx));

        var offset_x: i32 = SECONDARY_AXIS_POSITIONS[phase] * (2 - turn_i32);
        var stolen_y_movement: i32 = SECONDARY_AXIS_POSITIONS[phase] * @mod(turn_i32, 2);
        var offset_y: i32 = -16 + (@as(i32, @intCast(phase * 2))) - stolen_y_movement;

        var rotation_matrix = ROTATION_MATRICES[to_sz(self.in_edge)];
        offset_x = offset_x * rotation_matrix[0] + offset_y * rotation_matrix[1];
        offset_y = offset_x * rotation_matrix[2] + offset_y * rotation_matrix[3];

        // TODO: fix offset_y logic
        offset_y = 0;

        var pos = GAME.cell2posOff(self.cell_x, self.cell_y, offset_x, offset_y);
        self.x = pos.x;
        self.y = pos.y;

        var direction: i32 = @mod(SECONDARY_AXIS_SPEED[phase] * (turn_idx - 2) + to_i32(self.in_edge) * 2 + 4, 8);
        var leg_frame: usize = @divTrunc(phase, 4); // 16 phase cycle, 4 frames of animation

        var x128: usize = @intFromBool(self.fast);
        var x64: usize = @intFromBool(self.health == 2);
        var x32: usize = @intFromBool(self.head);

        // equivalent to:
        // self.image = "seg" + str(int(self.fast)) + str(int(self.health == 2)) + str(int(self.head)) + str(direction) + str(leg_frame)
        self.anim_idx = x128 * 128 + x64 * 64 + x32 * 32 + @as(usize, @intCast(direction)) * 4 + leg_frame;

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
