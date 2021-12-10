package opentype.tables;

import haxe.io.Bytes;

class Loca {
    public var glyphOffsets(default, null) : Array<Int>;
    public function new() {}

    public static function parse(data : Bytes, position : Int, numGlyphs : Int, shortVersion : Bool) : Loca {
        return parseLocaTable(data, position, numGlyphs, shortVersion);
    }
    // Parse the header `head` table
    static function parseLocaTable(data : Bytes, start : Int, numGlyphs : Int, shortVersion : Bool) {
        final p = new Parser(data, start);
        final loca = new Loca();

        final parseFn = shortVersion ? p.parseUShort : p.parseULong;
        // There is an extra entry after the last index element to compute the length of the last glyph.
        // That's why we use numGlyphs + 1.
        loca.glyphOffsets = [];
        for (i in 0...numGlyphs + 1) {
            var glyphOffset = parseFn();
            if (shortVersion) {
                // The short table version stores the actual offset divided by 2.
                glyphOffset *= 2;
            }
    
            loca.glyphOffsets.push(glyphOffset);
        }
    
    



        return loca;
    }
}