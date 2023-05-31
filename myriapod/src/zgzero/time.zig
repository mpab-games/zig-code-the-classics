const zgame = @import("zgame");

pub const Ticker = struct {
    ticks: u64,
    counter_ms: u64,
    count: u64,

    pub fn init() Ticker {
        return .{
            .ticks = zgame.time.get_ticks(),
            .counter_ms = 0,
            .count = 0,
        };
    }

    pub fn tick(self: *Ticker) void {
        var ticks_now = zgame.time.get_ticks();
        self.counter_ms = ticks_now - self.ticks;
        self.count += 1;
    }

    pub fn reset(self: *Ticker) void {
        self.ticks = zgame.time.get_ticks();
        self.counter_ms = 0;
        self.count = 0;
    }
};
