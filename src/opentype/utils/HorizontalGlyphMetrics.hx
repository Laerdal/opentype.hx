package opentype.utils;

class HorizontalGlyphMetrics {
    
    public function new(font : Font) {
        glyphMetrics = new FastIntMap();
        var chars = font.getChars();
        var glyphIndexes = font.getGlyphIndicies();
        for(char in chars) {
            var gi = font.charToGlyphIndex(char);
            
            var kerningPairsForChar = font.getKerningPairs(gi);
            var kerningsForCharMap : FastIntMap<Int> = null;
            if(Lambda.count(kerningPairsForChar) > 0) {
                kerningsForCharMap = new FastIntMap();
                for(pair in kerningPairsForChar) kerningsForCharMap[font.getGlyphByIndex(pair[0]).unicode] = pair[1];
            }

            var hgm : HGlyphMetrics = {
                advanceWidth : font.charToGlyph(char).advanceWidth,
                pairCount : Lambda.count(kerningPairsForChar),
                kerningPairs : kerningsForCharMap
            };
            glyphMetrics[char] = hgm;
        }
        defaultMetrics = new HGlyphMetrics(font.getGlyphByIndex(0).advanceWidth * 2, 0, null);
    }

    public inline function getGlyphMetricsForChar(charCode : Int) {
        if( glyphMetrics.exists(charCode) ) {
            return glyphMetrics[charCode];
        } else {
            return defaultMetrics;
        }
    }
    static var defaultMetrics : HGlyphMetrics;

    var glyphMetrics : FastIntMap<HGlyphMetrics>;
}

@:structInit
class HGlyphMetrics 
{
    public function new(advanceWidth : Int, pairCount : Int, kerningPairs : FastIntMap<Int>) {
        this.advanceWidth = advanceWidth;
        this.pairCount = pairCount;
        this.kerningPairs = kerningPairs;
    }
    public var advanceWidth(default, null) : Int;
    public var pairCount(default, null) : Int;
    public var kerningPairs(default, null) : FastIntMap<Int>;
} 