// -------------------------------------------------------
// language extensions/helpers

// TODO: use a template approach for this where the returned indexed type can be specified as u8, i32, ...
// to prevent messy casting on the index
pub fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}

pub const cast = struct {
    i8: i8,
    u8: u8,
    i16: i16,
    u16: u16,
    i32: i32,
    u32: u32,
    i64: i64,
    u64: u64,
    pub fn _(val: anytype) cast {
        return cast{
            .i8 = @as(i8, @intCast(val)),
            .i16 = @as(i16, @intCast(val)),
            .i32 = @as(i32, @intCast(val)),
            .i64 = @as(i64, @intCast(val)),
            .u8 = @as(u8, @intCast(val)),
            .u16 = @as(u16, @intCast(val)),
            .u32 = @as(u32, @intCast(val)),
            .u64 = @as(u64, @intCast(val)),
        };
    }
};

pub const div = struct {
    i8: i8,
    u8: u8,
    i16: i16,
    u16: u16,
    i32: i32,
    u32: u32,
    i64: i64,
    u64: u64,
    pub fn _(numerator: anytype, denominator: anytype) cast {
        return div{
            .i8 = @divTrunc(cast._(numerator).i8, cast._(denominator).i8),
            .i16 = @divTrunc(cast._(numerator).i8, cast._(denominator).i16),
            .i32 = @divTrunc(cast._(numerator).i8, cast._(denominator).i32),
            .i64 = @divTrunc(cast._(numerator).i8, cast._(denominator).i64),
            .u8 = @divTrunc(cast._(numerator).i8, cast._(denominator).u8),
            .u16 = @divTrunc(cast._(numerator).i8, cast._(denominator).u16),
            .u32 = @divTrunc(cast._(numerator).i8, cast._(denominator).u32),
            .u64 = @divTrunc(cast._(numerator).i8, cast._(denominator).u64),
        };
    }
};

pub const log = @import("std").debug.print;

// -------------------------------------------------------
