package opentype.tables;

import haxe.io.Bytes;

class GlyphTable {

    public function new() {}

    public static function parse(data : Bytes, position = 0, glyphOffsets : Array<Int>, font : Font, lowMemory : Bool) : GlyphSet {
        final p = new Parser(data, position);
        final glyph = new GlyphTable();
        return if (lowMemory) { 
            throw("Low memory mode not implemented");
            null;
        } else {
            //parseGlyfTableAll(data, start, loca, font);
            null;
        }
    }

    static function parseGlyfTableAll(data : Int, start : Int, glyphOffsets : Array<Int>, font : Font) {
        final glyphs = new GlyphSet(font);
        // The last element of the loca table is invalid.
        for (i in 0...glyphOffsets.length - 1) {
            final offset = glyphOffsets[i];
            final nextOffset = glyphOffsets[i + 1];
            if (offset != nextOffset) {
                //glyphs.push(i, glyphset.ttfGlyphLoader(font, i, parseGlyph, data, start + offset, buildPath));
            } else {
                //glyphs.push(i, glyphset.glyphLoader(font, i));
            }
        }
        return glyphs;
    }

}