pub fn prompt_line(buf: []u8, prompt: []const u8) ![]u8 {
    try std.io.getStdOut().writeAll(prompt);
    const result = try std.io.getStdIn().reader().readUntilDelimiter(buf, '\n');
    return result;
}
