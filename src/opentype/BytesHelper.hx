package opentype;

import haxe.io.Bytes;
using opentype.BytesHelper;

class BytesHelper {
	public static function fromCharCodes(codes : Array<Int>) {
		return Lambda.fold(codes, (c,r) -> r + String.fromCharCode(c), "");
	}

	public static inline function readU8(bytes : Bytes, position: Int = 0) : Int {
		return bytes.get(position);
	}
    
	public static inline function readChar(bytes : Bytes, position: Int = 0) : Int {
		var n = bytes.readU8(position);
		if (n >= 128) {
			return n - 256;
        }
		return n;
	}
    
    public static inline function readU16BE(bytes : Bytes, position: Int = 0) : Int {
		var first = bytes.get(position + 0);
		var second = bytes.get(position + 1);
		return first * 256 + second;
	}

	// Retrieve an unsigned 32-bit long from the DataView.
	// The value is stored in big endian.
	public static inline function readULong(p: Bytes, position: Int = 0): Int {
		var ch1 = p.readU8(position + 0);
		var ch2 = p.readU8(position + 1);
		var ch3 = p.readU8(position + 2);
		var ch4 = p.readU8(position + 3);
		return ch4 | (ch3 << 8) | (ch2 << 16) | (ch1 << 24);
	}	

}
