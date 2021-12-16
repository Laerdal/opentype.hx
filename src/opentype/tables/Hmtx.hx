package opentype.tables;

import opentype.Font;
import haxe.io.Bytes;

class Hmtx {
    public function new() {}

    public static function parse(data : Bytes, position : Int, font : Font, lowMemory : Bool) {
        if (lowMemory)
            parseHmtxTableOnLowMemory(data, position, font);
        else
            parseHmtxTableAll(data, position, font);
    }

    static function parseHmtxTableAll(data, start, font : Font) {
        var advanceWidth = 0;
        var leftSideBearing = 0;
        final p = new Parser(data, start);
        for (i in 0...font.numGlyphs) {
            // If the font is monospaced, only one entry is needed. This last entry applies to all subsequent glyphs.
            if (i < font.numberOfHMetrics) {
                advanceWidth = p.parseUShort();
                leftSideBearing = p.parseShort();
            }
    
            final glyph = font.glyphs.get(i);
            glyph.advanceWidth = advanceWidth;
            glyph.leftSideBearing = leftSideBearing;
        }
    }
    
    static function parseHmtxTableOnLowMemory(data : Bytes, start : Int, font : Font) {
        font._hmtxTableData = [];
    
        var advanceWidth = 0;
        var leftSideBearing = 0;
        final p = new Parser(data, start);
        for (i in 0...font.numGlyphs) {
            // If the font is monospaced, only one entry is needed. This last entry applies to all subsequent glyphs.
            if (i < font.numberOfHMetrics) {
                advanceWidth = p.parseUShort();
                leftSideBearing = p.parseShort();
            }
    
            font._hmtxTableData[i] = new Font.HorizontalMetrics(advanceWidth, leftSideBearing);
        }
    }
    
    // Parse the `hmtx` table, which contains the horizontal metrics for all glyphs.
    // This function augments the glyph array, adding the advanceWidth and leftSideBearing to each glyph.
    function parseHmtxTable(data, start, font : Font, lowMemory) {
        if (lowMemory)
            parseHmtxTableOnLowMemory(data, start, font);
        else
            parseHmtxTableAll(data, start, font);
    }
}