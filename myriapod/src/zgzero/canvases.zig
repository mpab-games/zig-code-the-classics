const zgame = @import("zgame"); // namespace
const Canvas = zgame.Canvas;
const images = @import("__gen/images.zig");

pub fn zig_logo(renderer: zgame.sdl.Renderer) !zgame.Canvas {
    const logo = @embedFile("./images/zig-logo.png");
    return try zgame.Canvas.loadPng(renderer, logo);
}

// TODO: auto-generate
pub fn space_list(list: *zgame.Canvas.List, renderer: zgame.sdl.Renderer) !void {
    var ps0 = try zgame.Canvas.loadPng(renderer, images.space0);
    var ps1 = try zgame.Canvas.loadPng(renderer, images.space1);
    var ps2 = try zgame.Canvas.loadPng(renderer, images.space2);
    var ps3 = try zgame.Canvas.loadPng(renderer, images.space3);
    var ps4 = try zgame.Canvas.loadPng(renderer, images.space4);
    var ps5 = try zgame.Canvas.loadPng(renderer, images.space5);
    var ps6 = try zgame.Canvas.loadPng(renderer, images.space6);
    var ps7 = try zgame.Canvas.loadPng(renderer, images.space7);
    var ps8 = try zgame.Canvas.loadPng(renderer, images.space8);
    var ps9 = try zgame.Canvas.loadPng(renderer, images.space9);
    var ps10 = try zgame.Canvas.loadPng(renderer, images.space10);
    var ps11 = try zgame.Canvas.loadPng(renderer, images.space11);
    var ps12 = try zgame.Canvas.loadPng(renderer, images.space12);
    var ps13 = try zgame.Canvas.loadPng(renderer, images.space13);

    try list.append(ps0);
    try list.append(ps1);
    try list.append(ps2);
    try list.append(ps3);
    try list.append(ps4);
    try list.append(ps5);
    try list.append(ps6);
    try list.append(ps7);
    try list.append(ps8);
    try list.append(ps9);
    try list.append(ps10);
    try list.append(ps11);
    try list.append(ps12);
    try list.append(ps13);
}

pub fn meanie_list(list: *zgame.Canvas.List, renderer: zgame.sdl.Renderer) !void {
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie00));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie01));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie02));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie10));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie11));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie12));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie20));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie21));
    try list.append(try zgame.Canvas.loadPng(renderer, images.meanie22));
}
