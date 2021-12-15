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
            parseGlyfTableAll(data, position, glyphOffsets, font);
        }
    }

    static function parseGlyfTableAll(data : Bytes, start : Int, glyphOffsets : Array<Int>, font : Font) {
        final glyphs = new GlyphSet(font);
        // The last element of the loca table is invalid.
        for (i in 0...glyphOffsets.length - 1) {
            final offset = glyphOffsets[i];
            final nextOffset = glyphOffsets[i + 1];
            if (offset != nextOffset) {
                glyphs.addGlyphLoader(i, GlyphSet.ttfGlyphLoader(font, i, /*parseGlyph, */data, start + offset/*, buildPath */));
            } else {
                glyphs.addGlyphLoader(i, GlyphSet.glyphLoader(font, i));
            }
        }
        return glyphs;
    }

}