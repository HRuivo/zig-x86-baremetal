const fmt = @import("std").fmt;
const mem = @import("std").mem;
const Writer = @import("std").io.Writer;

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const Colors = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

/// The current cursor row position
var row: usize = 0;

/// The current cursor column position
var column: usize = 0;

var color = vgaEntryColor(Colors.LightGray, Colors.Black);

//var buffer = @intToPtr([*]volatile u16, 0xB8000);
var buffer = @as([*]volatile u16, @ptrFromInt(0xB8000));

/// Create a VGA color from a foreground and background Colors enum.
fn vgaEntryColor(fg: Colors, bg: Colors) u8 {
    return @intFromEnum(fg) | (@intFromEnum(bg) << 4);
}

/// Create a VGA character entry from a character and a color
fn vgaEntry(uc: u8, newColor: u8) u16 {
    const c: u16 = newColor;
    return uc | (c << 8);
}

/// Set the active colors.
pub fn setColors(fg: Colors, bg: Colors) void {
    color = vgaEntryColor(fg, bg);
}

/// Set the active foreground color.
pub fn setForegroundColor(fg: Colors) void {
    color = (0xF0 & color) | @intFromEnum(fg);
}

/// Set the active background color.
pub fn setBackgroundColor(bg: Colors) void {
    color = (0x0F & color) | (@intFromEnum(bg) << 4);
}

/// Clear the screen using the active background color as the color to be painted.
pub fn clear() void {
    @memset(buffer[0..VGA_SIZE], vgaEntry(' ', color));
    //mem.set(u16, buffer[0..VGA_SIZE], vgaEntry(' ', color));
}

/// Sets the current cursor location.
pub fn setLocation(x: u8, y: u8) void {
    row = x % VGA_WIDTH;
    column = y & VGA_HEIGHT;
}

/// Puts a character at the specific coordinates using the specified color.
fn putCharAt(c: u8, newColor: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    buffer[index] = vgaEntry(c, newColor);
}

/// Prints a single character
pub fn putChar(c: u8) void {
    putCharAt(c, color, column, row);
    column += 1;
    if (column == VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT)
            row = 0;
    }
}

pub fn putString(data: []const u8) void {
    for (data) |c| {
        putChar(c);
    }
}

pub const writer = Writer(void, error{}, callback){ .context = {} };

fn callback(_: void, string: []const u8) error{}!usize {
    putString(string);
    return string.len;
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    fmt.format(writer, format, args) catch unreachable;
}
