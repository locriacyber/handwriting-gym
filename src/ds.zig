const std = @import("std");

pub fn FixedSizedQueue (comptime T: type, comptime max: usize) type {
    return struct {
        buffer: [20]T,
        len: usize,

        const Self = @This();

        pub fn init() Self {
            return Self{
                .len = 0,
                .buffer = undefined,
            };
        }

        pub fn slice(this: *Self) []T {
            return this.buffer[0..this.len];
        }

        pub fn clear(this: *Self) void {
            this.len = 0;   
        }

        pub fn shift(this: *Self) ?T {
            if (this.len == 0) return null;
            const ret = this.buffer[0];
            this.len -= 1;
            var i: usize = 0;
            while (i < this.len) : (i += 1) {
                this.buffer[i] = this.buffer[i + 1];
            }
            return ret;
        }

        pub fn push(this: *Self, t: T) ?T {
            if (this.len < max) {
                this.push_no_check(t);
                return null;
            } else {
                std.debug.assert(this.len == max);
                const ret = this.shift();
                this.push_no_check(t);
                return ret;
            }
        }

        fn push_no_check(this: *Self, t: T) void {
            this.buffer[this.len] = t;
            this.len += 1;
        }
    };
}