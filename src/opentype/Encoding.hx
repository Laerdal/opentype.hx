package opentype;

import opentype.tables.Cmap;

interface IEncoding {
    function getChars() : Array<Int>;
    function charToGlyphIndex(char : Int) : Int;
    function hasChar(char : Int) : Bool;
    function getIndicies() : Array<Int>;
}

class DefaultEncoding 
implements IEncoding
{
    var glyphs : GlyphSet;   
    public function new(font : Font) {
        glyphs = font.glyphs != null ? font.glyphs : new GlyphSet(font);
    }

    public function getChars() : Array<Int> {
        var chars = [];
        for (g in 0...glyphs.length) {
            final glyph = glyphs.get(g);
            chars = chars.concat(glyph.unicodes);
        }
        return chars;
    }

    public function hasChar(char : Int) : Bool {
        return false;
    }

    public function charToGlyphIndex(code : Int) : Int {
        for (i in 0...glyphs.length) {
            final glyph = glyphs.get(i);
            for (j in 0...glyph.unicodes.length) {
                if (glyph.unicodes[j] == code) {
                    return i;
                }
            }
        }
        return -1;    
    }

    public function getIndicies() : Array<Int> {
        return glyphs.getIndicies();
    }
}

class CmapEncoding 
implements IEncoding
{
    var cmap : Cmap;
    public function new(cmap : Cmap) {
        this.cmap = cmap;
    }

    public function getChars() : Array<Int> {
        return [for(k => v in cmap.glyphIndexMap) k ];
    }

    public function hasChar(char : Int) : Bool {
        return cmap.glyphIndexMap.exists(char);
    }

    public function charToGlyphIndex(cpa : Int) : Int {
        return if(cmap.glyphIndexMap.exists(cpa)) {
            cmap.glyphIndexMap[cpa];
        } else {
            0;
        } 
    }

    public function getIndicies() : Array<Int> {
        return [for(k => v in cmap.glyphIndexMap) v];
    }    
}

class Encoding {
    /**
    * @alias opentype.addGlyphNames
    * @param {opentype.Font}
    * @param {Bool}
    */
    public static function addGlyphNames(font : Font, lowMemory : Bool) {
        if (lowMemory) {
            //addGlyphNamesToUnicodeMap(font);
        } else {
            addGlyphNamesAll(font);
        }
    }

    public static function addGlyphNamesAll(font : Font) {
        var glyph;
        //final glyphIndexMap = font.tables.cmap.glyphIndexMap;
        //final charCodes = Lambda.array(glyphIndexMap.keys());
        for(char => index in font.tables.cmap.glyphIndexMap) {
            glyph = font.glyphs.get(index);
            glyph.addUnicode(char);
        }
/*
        for (i in 0...charCodes.length) {
            final c = charCodes[i];
            final glyphIndex = glyphIndexMap[c];
            glyph = font.glyphs.get(glyphIndex);
            glyph.addUnicode(parseInt(c));
        }
*/    
/*
        for (i in 0...font.glyphs.length) {
            glyph = font.glyphs.get(i);
            if (font.cffEncoding ) {
                if (font.isCIDFont) {
                    glyph.name = 'gid' + i;
                } else {
                    glyph.name = font.cffEncoding.charset[i];
                }
            } else if (font.glyphNames.names) {
                glyph.name = font.glyphNames.glyphIndexToName(i);
            }
        }
        */    
    }
/*    
    function addGlyphNamesToUnicodeMap(font) {
        font._IndexToUnicodeMap = {};
    
        const glyphIndexMap = font.tables.cmap.glyphIndexMap;
        const charCodes = Object.keys(glyphIndexMap);
    
        for (let i = 0; i < charCodes.length; i += 1) {
            const c = charCodes[i];
            let glyphIndex = glyphIndexMap[c];
            if (font._IndexToUnicodeMap[glyphIndex] === undefined) {
                font._IndexToUnicodeMap[glyphIndex] = {
                    unicodes: [parseInt(c)]
                };
            } else {
                font._IndexToUnicodeMap[glyphIndex].unicodes.push(parseInt(c));
            }
        }
    }    
*/
}