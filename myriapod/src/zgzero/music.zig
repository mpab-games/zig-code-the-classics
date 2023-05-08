// TODO: auto-generate

const zg = @import("zgame"); // namespace
const Sound = zg.mixer.Sound;

const music = struct {};
pub const Music = struct {
    pub fn init() !Music {
        // TODO: auto-generate
        return .{};
    }
    pub fn play(self: Music, str: []const u8) void {
        _ = self;
        _ = str;
    }
    pub fn set_volume(self: Music, vol: f32) void {
        _ = self;
        _ = vol;
    }
};
