package opentype.tables;

import haxe.io.Bytes;
using opentype.BytesHelper;

class Cmap 
{

    public function new() {
        //subtableParsers = [null, parseLookup2];         // subtableParsers[0] is unused
        glyphIndexMap = new Map();
    }

    public var version(default, null) : Float = -1;
    public var numTables(default, null) : Int = 0;
    public var format(default, null) : Int = 0; 
    public var groupCount(default, null) : Int = 0; 
    public var glyphIndexMap(default, null) : Map<Int,Int>;
    public var length(default, null) : Int;
    public var language(default, null) : Int;
    public var segCount(default, null) : Int;
    //public var scripts : Array<ScriptRecord> = [];
    //public var lookups(default, null) : Array<LookupTable> = [];
    //public var features(default, null) : Array<FeatureTable> = [];
    //features: p.parseFeatureList(),

    public static function parse(data : Bytes, position = 0) : Cmap {
        return parseCmapTable(data, position);
    }

    static function parseCmapTableFormat12(cmap : Cmap, p : Parser) {
        //Skip reserved.
        p.parseUShort();
    
        // Length in bytes of the sub-tables.
        cmap.length = p.parseULong();
        cmap.language = p.parseULong();
    
        var groupCount;
        cmap.groupCount = groupCount = p.parseULong();
        cmap.glyphIndexMap = new Map();
    
        for (i in 0...groupCount) {
            final startCharCode = p.parseULong();
            final endCharCode = p.parseULong();
            var startGlyphId = p.parseULong();
    
            for (c in startCharCode...endCharCode) {
                cmap.glyphIndexMap[c] = startGlyphId;
                startGlyphId++;
            }
        }
    }
    
    static function parseCmapTableFormat4(cmap : Cmap, p : Parser, data, start, offset) {
        // Length in bytes of the sub-tables.
        cmap.length = p.parseUShort();
        cmap.language = p.parseUShort();
    
        // segCount is stored x 2.
        var segCount;
        cmap.segCount = segCount = p.parseUShort() >> 1;
    
        // Skip searchRange, entrySelector, rangeShift.
        p.skipUShort(3);
    
        // The "unrolled" mapping from character codes to glyph indices.
        cmap.glyphIndexMap = new Map();
        final endCountParser = new Parser(data, start + offset + 14);
        final startCountParser = new Parser(data, start + offset + 16 + segCount * 2);
        final idDeltaParser = new Parser(data, start + offset + 16 + segCount * 4);
        final idRangeOffsetParser = new Parser(data, start + offset + 16 + segCount * 6);
        var glyphIndexOffset = start + offset + 16 + segCount * 8;
        for (i in 0...segCount - 1) {
            var glyphIndex;
            final endCount = endCountParser.parseUShort();
            final startCount = startCountParser.parseUShort();
            final idDelta = idDeltaParser.parseShort();
            final idRangeOffset = idRangeOffsetParser.parseUShort();
            for (c in startCount...endCount + 1) {
                if (idRangeOffset != 0) {
                    // The idRangeOffset is relative to the current position in the idRangeOffset array.
                    // Take the current offset in the idRangeOffset array.
                    glyphIndexOffset = (idRangeOffsetParser.offset + idRangeOffsetParser.relativeOffset - 2);
    
                    // Add the value of the idRangeOffset, which will move us into the glyphIndex array.
                    glyphIndexOffset += idRangeOffset;
    
                    // Then add the character index of the current segment, multiplied by 2 for USHORTs.
                    glyphIndexOffset += (c - startCount) * 2;
                    glyphIndex = data.readU16BE(glyphIndexOffset);
                    if (glyphIndex != 0) {
                        glyphIndex = (glyphIndex + idDelta) & 0xFFFF;
                    }
                } else {
                    glyphIndex = (c + idDelta) & 0xFFFF;
                }
    
                cmap.glyphIndexMap[c] = glyphIndex;
            }
        }
    }
    
    // Parse the `cmap` table. This table stores the mappings from characters to glyphs.
    // There are many available formats, but we only support the Windows format 4 and 12.
    // This function returns a `CmapEncoding` object or null if no supported format could be found.
    static function parseCmapTable(data : Bytes, start : Int) {
        final cmap = new Cmap();
        cmap.version = data.readU16BE(start);
        Check.assert(cmap.version == 0, 'cmap table version should be 0.');
    
        // The cmap table can contain many sub-tables, each with their own format.
        // We're only interested in a "platform 0" (Unicode format) and "platform 3" (Windows format) table.
        cmap.numTables = data.readU16BE(start + 2);
        var offset = -1;
        var i = cmap.numTables - 1;
        while(i-- >= 0) {
        //for (var i = cmap.numTables - 1; i >= 0; i -= 1) {
            final platformId = data.readU16BE(start + 4 + (i * 8));
            final encodingId = data.readU16BE(start + 4 + (i * 8) + 2);
            if ((platformId == 3 && (encodingId == 0 || encodingId == 1 || encodingId == 10)) ||
                (platformId == 0 && (encodingId == 0 || encodingId == 1 || encodingId == 2 || encodingId == 3 || encodingId == 4))) {
                offset = data.readULong(start + 4 + (i * 8) + 4);
                break;
            }
        }
    
        if (offset == -1) {
            // There is no cmap table in the font that we support.
            throw('No valid cmap sub-tables found.');
        }
    
        final p = new Parser(data, start + offset);
        cmap.format = p.parseUShort();
    
        if (cmap.format == 12) {
            parseCmapTableFormat12(cmap, p);
        } else if (cmap.format == 4) {
            parseCmapTableFormat4(cmap, p, data, start, offset);
        } else {
            throw('Only format 4 and 12 cmap tables are supported (found format ' + cmap.format + ').');
        }
    
        return cmap;
    }

}