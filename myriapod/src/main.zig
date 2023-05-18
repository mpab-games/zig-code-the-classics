const std = @import("std");
const dbg = std.log.debug;
const info = std.log.info;
const zgame = @import("zgame"); // namespace
const ZigGame = zgame.ZigGame; // context
const sdl = zgame.sdl;
const zgzero = @import("zgzero/zgzero.zig");
const SpriteFactory = @import("sprite.zig").Factory;
const images = zgzero.images;
const PressSpaceSprite = @import("sprites/press_space.zig").PressSpace;

const SCREEN_WIDTH = 480;
const SCREEN_HEIGHT = 800;
const SCREEN_TITLE = "Myriapod";
const NUM_GRID_ROWS = 25;
const NUM_GRID_COLS = 14;

const PLYR_START_X = 240;
const PLYR_START_Y = 768;
const PRESS_START_Y = 420;

const GameState = enum {
    MENU,
    PLAY,
    GAME_OVER,
};

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

const Game = struct {
    const Self = Game;
    bg_image: zgame.Canvas,
    title_image: zgame.Canvas,
    press_space: PressSpaceSprite,
    //logo: zgame.Canvas,
    time: zgzero.time.Ticker,

    wave: i32 = -1,
    press_space_anim: usize = 0,

    fn init(zg: *ZigGame) !Game {
        var bg_image = try zgame.Canvas.loadPng(zg.renderer, images.bg0);
        var title_image = try zgame.Canvas.loadPng(zg.renderer, images.title);
        var press_space = try PressSpaceSprite.init(zg, 0, PRESS_START_Y);
        //var logo = try zgzero.canvases.zig_logo(zg.renderer);

        return .{
            .bg_image = bg_image,
            .title_image = title_image,
            .press_space = press_space,
            .time = zgzero.time.Ticker.init(),
        };
    }

    fn update(self: *Self, gctx: *GameContext) void {
        _ = gctx;

        if (self.time.counter_ms > 50) {
            self.press_space.update();
            self.time.reset();
        }
    }

    fn draw_bg(self: Self, gctx: *GameContext) void {
        self.bg_image.blit(gctx.zg.renderer);
    }

    fn draw_title(self: Self, gctx: *GameContext) void {
        self.title_image.blit(gctx.zg.renderer);
        //self.logo.blit_at(gctx.zg.renderer, 0, 100);
    }

    fn draw_press_space(self: Self, gctx: *GameContext) void {
        self.press_space.draw(gctx.zg);
    }
};

const GameContext = struct {
    zg: *ZigGame,
    mixer: *zgzero.mixer.Mixer,
    font: *zgzero.font.Font,
    game_level: u16 = 1,
    lives: u64 = 0,
    player_score_edit_pos: usize = 0,
    game_state: GameState = GameState.GAME_OVER,
    bounds: sdl.Rectangle,
    playfield: zgame.sprite.Group(SpriteFactory.Type) = .{},
    bullets: zgame.sprite.Group(SpriteFactory.Type) = .{},

    input: InputEvents = .{},
    stats_hash: usize = 0,

    time: i32 = 0,
    player: usize = 0,

    game: Game,

    pub fn init(zg: *ZigGame, mixer: *zgzero.mixer.Mixer, font: *zgzero.font.Font) !GameContext {
        var game = try Game.init(zg);
        var gctx: GameContext = .{
            .zg = zg,
            .mixer = mixer,
            .font = font,
            .bounds = sdl.Rectangle{ .x = 0, .y = 0, .width = zg.size.width_pixels, .height = zg.size.height_pixels },
            .game = game,
        };

        var factory = SpriteFactory.init(zg);
        var player_sprite = try SpriteFactory.player.new(factory, 0, 0);
        gctx.player = try gctx.playfield.add(player_sprite);

        var enemy = try SpriteFactory.flying_enemy.new(factory, 100);
        _ = try gctx.playfield.add(enemy);

        return gctx;
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

fn set_game_state(gctx: *GameContext, state: GameState) void {
    gctx.game_state = state;
}

// state handlers
const state_menu = struct {
    const state = state_menu;
    fn update(gctx: *GameContext) !void {
        if (!gctx.input.ie_key_down.is_empty) {
            var key = gctx.input.ie_key_down.val.event.key_down;
            var scancode = key.scancode;
            if (scancode == sdl.Scancode.space) {
                set_game_state(gctx, GameState.PLAY);
                gctx.mixer.sounds.wave0.play();
                var player_sprite = &gctx.playfield.list.items[gctx.player];
                var pd = player_sprite.get();
                pd.x = PLYR_START_X;
                pd.y = PLYR_START_Y;
                player_sprite.set(pd);
            }
        }

        gctx.game.update(gctx);
    }
    fn draw(gctx: *GameContext) !void {
        gctx.game.draw_bg(gctx);
        gctx.game.draw_title(gctx);
        gctx.game.draw_press_space(gctx);
    }
};

const state_play = struct {
    const state = state_play;
    fn update(gctx: *GameContext) !void {
        if (!gctx.input.ie_key_down.is_empty) {
            var key = gctx.input.ie_key_down.val.event.key_down;
            var scancode = key.scancode;

            var dx: i32 = @as(i32, @boolToInt(scancode == sdl.Scancode.right)) - @as(i32, @boolToInt(scancode == sdl.Scancode.left));
            var dy: i32 = @as(i32, @boolToInt(scancode == sdl.Scancode.down)) - @as(i32, @boolToInt(scancode == sdl.Scancode.up));

            var player_sprite = &gctx.playfield.list.items[gctx.player];
            var pd = player_sprite.get();
            pd.x += dx;
            pd.y += dy;
            player_sprite.set(pd);

            if (scancode == sdl.Scancode.space) {
                gctx.mixer.sounds.laser0.play();

                var factory = SpriteFactory.init(gctx.zg);
                var bullet_sprite = try SpriteFactory.bullet.new(factory, pd.x, pd.y, -8);
                _ = try gctx.bullets.add(bullet_sprite);
            }
        }

        if (gctx.game.time.counter_ms > 50) {
            gctx.bullets.update();
            gctx.playfield.update();
            gctx.game.time.reset();
        }
    }

    fn draw(gctx: *GameContext) !void {
        gctx.game.draw_bg(gctx);
        gctx.playfield.draw(gctx.zg);
        gctx.bullets.draw(gctx.zg);
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

    switch (gctx.game_state) {
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

pub fn main() !void {
    var zgContext = try ZigGame.init(SCREEN_TITLE, SCREEN_WIDTH, SCREEN_HEIGHT);
    var mixer = try zgzero.mixer.Mixer.init();
    var font = try zgzero.font.Font.init(&zgContext);
    var gctx = try GameContext.init(&zgContext, &mixer, &font);
    set_game_state(&gctx, GameState.MENU);

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
