package opentype.utils;

class HorizontalGlyphMetrics {
    
    public function new(font : Font) {
        advanceWidths = new Map();
        kerningPairs = [];
        var chars = font.getChars();
        var glyphIndexes = font.getGlyphIndicies();
        if(chars.length != glyphIndexes.length) throw('Error, cannot construct Horizontal glyph metrics: Number of chars differs from number of indexes');
        
        for(char in chars) {
            advanceWidths[char] = font.charToGlyph(char).advanceWidth;
            var gi = font.charToGlyphIndex(char);
            kerningPairs[char] = [
                for(pair in font.getKerningPairs(gi)) {
                    
                    font.getGlyphByIndex(pair[0]).unicode => pair[1];
                }
            ];
        }
    }

    public inline function getAdvanceWidth(charCode) : Int {
        return advanceWidths[charCode];
    }

    public inline function getKerningForPair(leftChar : Int, rightChar : Int) : Int {
        if(!kerningPairs.exists(leftChar)) return 0;
        if(!kerningPairs[leftChar].exists(rightChar)) return 0;
        return kerningPairs[leftChar][rightChar];
    }

    var advanceWidths : Map<Int, Int>;
    var kerningPairs : Map<Int, Map<Int, Int>>;
}
