const std = @import("std");

const zg = @import("zgame"); // namespace
const Sounds = @import("__gen/sounds.zig").Sounds;
const Music = @import("music.zig").Music;

pub const Mixer = struct {
    init_flags: c_int,
    music: Music,
    sounds: Sounds,

    pub fn init() !Mixer {
        var init_flags = try zg.mixer.Mixer.init();
        var music = try Music.init();
        var sounds = try Sounds.init();
        return .{
            .init_flags = init_flags,
            .music = music,
            .sounds = sounds,
        };
    }
};
