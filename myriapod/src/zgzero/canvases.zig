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

pub fn segment_list(list: *zgame.Canvas.List, renderer: zgame.sdl.Renderer) !void {
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00000));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00001));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00002));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00003));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00010));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00011));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00012));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00013));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00020));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00021));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00022));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00023));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00030));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00031));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00032));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00033));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00040));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00041));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00042));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00043));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00050));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00051));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00052));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00053));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00060));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00061));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00062));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00063));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00070));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00071));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00072));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00073));

    // ------------------------------------------------------------------

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00100));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00101));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00102));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00103));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00110));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00111));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00112));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00113));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00120));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00121));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00122));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00123));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00130));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00131));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00132));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00133));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00140));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00141));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00142));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00143));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00150));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00151));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00152));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00153));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00160));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00161));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00162));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00163));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00170));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00171));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00172));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg00173));

    // ------------------------------------------------------------------

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10000));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10001));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10002));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10003));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10010));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10011));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10012));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10013));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10020));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10021));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10022));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10023));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10030));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10031));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10032));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10033));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10040));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10041));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10042));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10043));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10050));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10051));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10052));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10053));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10060));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10061));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10062));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10063));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10070));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10071));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10072));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10073));

    // ------------------------------------------------------------------

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10100));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10101));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10102));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10103));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10110));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10111));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10112));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10113));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10120));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10121));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10122));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10123));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10130));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10131));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10132));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10133));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10140));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10141));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10142));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10143));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10150));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10151));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10152));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10153));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10160));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10161));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10162));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10163));

    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10170));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10171));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10172));
    try list.append(try zgame.Canvas.loadPng(renderer, images.seg10173));
}
