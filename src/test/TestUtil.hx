
import haxe.io.UInt8Array;
import haxe.io.Bytes;

class TestUtil {

    public static function hex(bytes : Array<Int>) : String {
        final values = [];
        for (i in 0...bytes.length) {
            final b = bytes[i];
            if (b < 16) {
                values.push('0' + StringTools.hex(b));
            } else {
                values.push(StringTools.hex(b));
            }
        }
        return values.join(' ').toUpperCase();
    }

    public static function unhex(str : String) : Bytes {
        str = str.split(' ').join('');
        return haxe.io.Bytes.ofHex(str);
    }

    public static function unhexArray(str : String) : Array<Int> {
        return [ for(i in UInt8Array.fromBytes(unhex(str))) i ];
    }
}