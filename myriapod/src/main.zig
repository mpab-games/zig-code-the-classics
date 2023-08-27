const std = @import("std");
const dbg = std.log.debug;
const info = std.log.info;
const zgame = @import("zgame"); // namespace
const zgu = zgame.util;
const range = zgu.range;
const ZigGame = zgame.ZigGame; // context
const sdl = zgame.sdl;
const zgzero = @import("zgzero/zgzero.zig");

const SpriteFactory = @import("sprite.zig").Factory;
const images = zgzero.images;

const GAME = @import("game.zig");

const InputEvent = struct {
    const Event = union {
        event: sdl.Event,
        empty: void,
    };
    val: Event = .{ .empty = {} },
    is_empty: bool = true,

    fn init(event: sdl.Event) InputEvent {
        return .{
            .is_empty = false,
            .val = .{ .event = event },
        };
    }
};

const InputEvents = struct {
    ie_mouse_motion: InputEvent = .{},
    ie_mouse_button_down: InputEvent = .{},
    ie_key_down: InputEvent = .{},
};

const GameContext = struct {
    const Self = GameContext;
    zg: *ZigGame,
    mixer: *zgzero.mixer.Mixer,
    font: *zgzero.font.Font,
    wave: u16 = 0,
    lives: u64 = 0,
    player_score_edit_pos: usize = 0,

    bounds: sdl.Rectangle,
    factory: SpriteFactory,
    playfield: zgame.sprite.Group(SpriteFactory.Type, GAME.Game) = .{},
    bullets: zgame.sprite.Group(SpriteFactory.Type, GAME.Game) = .{},
    segments: zgame.sprite.Group(SpriteFactory.Type, GAME.Game) = .{},

    input: InputEvents = .{},
    stats_hash: usize = 0,

    time: i32 = 0,
    player: usize = 0,
    enemy: usize = 0,

    game: GAME.Game,

    pub fn init(zg: *ZigGame, mixer: *zgzero.mixer.Mixer, font: *zgzero.font.Font) !Self {
        var game = try GAME.Game.init(zg);
        var gctx: Self = .{
            .zg = zg,
            .mixer = mixer,
            .font = font,
            .bounds = sdl.Rectangle{ .x = 0, .y = 0, .width = zg.size.width_pixels, .height = zg.size.height_pixels },
            .game = game,
            .factory = SpriteFactory.init(zg),
        };

        // state with player sprite off-screen
        var player_sprite = try SpriteFactory.player.new(gctx.factory, -100, -100);
        gctx.player = try gctx.playfield.add(player_sprite);

        var enemy_sprite = try SpriteFactory.flying_enemy.new(gctx.factory, 100);
        gctx.enemy = try gctx.playfield.add(enemy_sprite);

        return gctx;
    }

    pub fn handle_new_wave(self: *Self) !void {
        if (self.segments.list.items.len == 0) {
            // game.play_sound("wave");
            self.wave += 1;
            self.time = 0;
            try self.add_segments();
        }
    }

    fn add_segments(self: *Self) !void {
        var num_segments = 8 + ((self.wave >> 2) << 1); // On the first four waves there are 8 segments - then 10, and so on
        for (range(num_segments), 0..) |_, i| {
            //var cell_x: i32 = 8 - @intCast(i32, i);
            var cell_x: i32 = -1 - @as(i32, @intCast(i));
            //var cell_y: i32 = 0;
            var cell_y: i32 = 16;
            // Determines whether segments take one or two hits to kill, based on the wave number.
            // e.g. on wave 0 all segments take one hit; on wave 1 they alternate between one and two hits
            var health: i32 = 1; //[[1,1],[1,2],[2,2],[1,1]][self.wave % 4][i % 2];
            var fast = self.wave % 4 == 3; // Every fourth myriapod moves faster than usual
            var head = i == 0; // The first segment of each myriapod is the head
            var segment = try SpriteFactory.segment.new(self.factory, cell_x, cell_y, health, fast, head);
            _ = try self.segments.add(segment);
            //dbg("added segment: {}", .{i});
        }
    }
};

// event handlers

fn process_mouse_motion(gctx: *GameContext) void {
    if (gctx.input.ie_mouse_motion.is_empty) {
        return;
    }

    var bat = &gctx.playfield.list.items[gctx.bat_idx];
    var data = bat.get();
    var batx = gctx.input.ie_mouse_motion.val.event.mouse_motion.x - @divTrunc(data.width, 2);
    data.x = batx;
    bat.set(data);
}

// state handlers
const state_menu = struct {
    const state = state_menu;
    fn update(gctx: *GameContext) !void {
        if (!gctx.input.ie_key_down.is_empty) {
            var key = gctx.input.ie_key_down.val.event.key_down;
            var scancode = key.scancode;
            if (scancode == sdl.Scancode.space) {
                set_game_state(&gctx.game, GAME.State.PLAY);
                gctx.mixer.sounds.wave0.play();
                var player_sprite = &gctx.playfield.list.items[gctx.player];
                var pd = player_sprite.get();
                pd.x = GAME.PLYR_START_X;
                pd.y = GAME.PLYR_START_Y;
                pd.state = 1;
                player_sprite.set(pd);
            }
        }

        if (gctx.game.time.count % 4 == 0) {
            gctx.game.press_space.update(&gctx.game);
            //gctx.game.time.reset();
        }

        var fe = &gctx.playfield.list.items[gctx.enemy].flying_enemy;

        if (fe.health <= 0 or fe.x < -35 or fe.x > 515) {
            fe.reset(GAME.PLYR_START_X);
        }

        try gctx.handle_new_wave();

        gctx.playfield.update(&gctx.game);
        gctx.segments.update(&gctx.game);
    }

    fn draw(gctx: *GameContext) !void {
        gctx.game.bg_image.blit(gctx.zg.renderer);

        gctx.game.bg_image.blit(gctx.zg.renderer);
        gctx.playfield.draw(gctx.zg);
        gctx.segments.draw(gctx.zg);

        gctx.game.title_image.blit(gctx.zg.renderer);
        gctx.game.press_space.draw(gctx.zg);
    }
};

const state_play = struct {
    const state = state_play;

    fn update(gctx: *GameContext) !void {
        var player_sprite = &gctx.playfield.list.items[gctx.player];
        var player_data = player_sprite.get();

        if (!gctx.input.ie_key_down.is_empty) {
            var key = gctx.input.ie_key_down.val.event.key_down;
            var scancode = key.scancode;

            var dx: i32 = @as(i32, @intFromBool(scancode == sdl.Scancode.right)) - @as(i32, @intFromBool(scancode == sdl.Scancode.left));
            var dy: i32 = @as(i32, @intFromBool(scancode == sdl.Scancode.down)) - @as(i32, @intFromBool(scancode == sdl.Scancode.up));

            player_data.x += dx;
            player_data.y += dy;
            player_sprite.set(player_data);

            if (scancode == sdl.Scancode.space) {
                gctx.mixer.sounds.laser0.play();

                var factory = SpriteFactory.init(gctx.zg);
                var bullet_sprite = try SpriteFactory.bullet.new(factory, player_data.x, player_data.y, -8);
                _ = try gctx.bullets.add(bullet_sprite);
            }
        }

        var fe = &gctx.playfield.list.items[gctx.enemy].flying_enemy;

        if (fe.health <= 0 or fe.x < -35 or fe.x > 515) {
            fe.reset(player_data.x);
        }

        try gctx.handle_new_wave();

        gctx.bullets.update(&gctx.game);
        gctx.playfield.update(&gctx.game);
        gctx.segments.update(&gctx.game);
    }

    fn draw(gctx: *GameContext) !void {
        gctx.game.bg_image.blit(gctx.zg.renderer);
        gctx.playfield.draw(gctx.zg);
        gctx.segments.draw(gctx.zg);
        gctx.bullets.draw(gctx.zg);
        gctx.game.draw_lives();
        gctx.game.draw_score();
    }
};

const state_game_over = struct {
    const state = state_game_over;
    fn update(gctx: *GameContext) !void {
        _ = gctx;
    }
    fn draw(gctx: *GameContext) !void {
        _ = gctx;
    }
};

fn run_game(gctx: *GameContext) !bool {
    gctx.game.occupied.list.clearAndFree();
    gctx.input = .{}; // clear last events
    gctx.game.time.tick();

    while (sdl.pollEvent()) |event| {
        switch (event) {
            .quit => return false,
            .mouse_motion => {
                gctx.input.ie_mouse_motion = InputEvent.init(event);
            },
            .mouse_button_down => {
                gctx.input.ie_mouse_button_down = InputEvent.init(event);
            },
            .key_down => {
                gctx.input.ie_key_down = InputEvent.init(event);
            },
            else => {},
        }
    }

    switch (gctx.game.state) {
        .MENU => {
            try state_menu.update(gctx);
            try state_menu.draw(gctx);
        },
        .PLAY => {
            try state_play.update(gctx);
            try state_play.draw(gctx);
        },

        .GAME_OVER => {
            try state_game_over.update(gctx);
            try state_game_over.draw(gctx);
        },
    }

    return true;
}

// add any game state transition logic here
pub fn set_game_state(game: *GAME.Game, state: GAME.State) void {
    game.state = state;
}

pub fn main() !void {
    var zgContext = try ZigGame.init(GAME.SCREEN_TITLE, GAME.SCREEN_WIDTH, GAME.SCREEN_HEIGHT);
    var mixer = try zgzero.mixer.Mixer.init();
    var font = try zgzero.font.Font.init(&zgContext);
    var gctx = try GameContext.init(&zgContext, &mixer, &font);
    set_game_state(&gctx.game, GAME.State.MENU);

    mixer.music.play("theme");
    mixer.music.set_volume(0.4);

    // var fps = zgzero.time.Ticker.init();
    // var frames: usize = 0;

    var running: bool = true;
    while (running) {
        running = try run_game(&gctx);
        gctx.zg.renderer.present();
        // fps.tick();
        // frames += 1;
        // if (fps.counter_ms >= 1000) {
        //     info("fps={}", .{frames});
        //     fps.reset();
        //     frames = 0;
        // }
    }

    zgame.quit();
}
