package opentype;

import opentype.Glyph;

@:structInit
class GlyphWrapper {
    public function new(glyph, loader) {
        this.glyph = glyph;
        this.loader = loader;
    }
    public var glyph : Glyph;
    public var loader : Void -> Glyph;
}


class GlyphSet {
    
    var glyphs : Map<Int, GlyphWrapper>;
    var glyphLoaders : Map<Int, Void -> Glyph>;
    public function new(font : Font, ?glyphs : Array<Glyph>) {
        this.glyphs = new Map();
        this.glyphLoaders = new Map();
        if(glyphs != null) {
            for (i in 0...glyphs.length) {
                final glyph = glyphs[i];
                //glyph.path.unitsPerEm = font.unitsPerEm;
                this.glyphs[i] = new GlyphWrapper(glyph, null);
            }            
        }
    }

    /**
    * @param  {number} index
    * @param  {Glyph}
    */
    public function addGlyph(index : Int, glyph : Glyph) {
        glyphs[index] = new GlyphWrapper(glyph, null);
        length++;
    };
    
    /**
    * @param  {number} index
    * @param  {Void -> Glyph}
    */
    public function addGlyphLoader(index : Int, loader : Void -> Glyph) {
        glyphs[index] = new GlyphWrapper(null, loader);
        length++;
    };

    public function get(index : Int) : Glyph {
        // this.glyphs[index] is 'undefined' when low memory mode is on. glyph is pushed on request only.
        if (glyphs[index].glyph == null) {
            /*
            this.font._push(index);
            if (typeof this.glyphs[index] == 'function') {
                this.glyphs[index] = this.glyphs[index]();
            }
            */
            glyphs[index].glyph = glyphs[index].loader();

/*
            var glyph = this.glyphs[index];
            var unicodeObj = this.font._IndexToUnicodeMap[index];

            if (unicodeObj) {
                for (j in 0...unicodeObj.unicodes.length)
                    glyph.addUnicode(unicodeObj.unicodes[j]);
            }

            if (this.font.cffEncoding) {
                if (this.font.isCIDFont) {
                    glyph.name = 'gid' + index;
                } else {
                    glyph.name = this.font.cffEncoding.charset[index];
                }
            } else if (this.font.glyphNames.names) {
                glyph.name = this.font.glyphNames.glyphIndexToName(index);
            }
            this.glyphs[index].advanceWidth = this.font._hmtxTableData[index].advanceWidth;
            this.glyphs[index].leftSideBearing = this.font._hmtxTableData[index].leftSideBearing;
        */
        } else {
            /*
            if (typeof this.glyphs[index] === 'function') {
                this.glyphs[index] = this.glyphs[index]();
            }
            */
        }

        return glyphs[index].glyph;
    }

    public function getIndicies() : Array<Int> {
        return [for(k => v in glyphs) v.glyph.index];
    }

    public var length(default, null) : Int;

    /**
    * @alias opentype.glyphLoader
    * @param  {opentype.Font} font
    * @param  {number} index
    * @return {opentype.Glyph}
    */
    public static function glyphLoader(font, index) : Void -> Glyph {
        return () -> new Glyph({index: index/*, font: font*/});
    }    

    /**
    * Generate a stub glyph that can be filled with all metadata *except*
    * the "points" and "path" properties, which must be loaded only once
    * the glyph's path is actually requested for text shaping.
    * @alias opentype.ttfGlyphLoader
    * @param  {opentype.Font} font
    * @param  {number} index
    * @param  {Function} parseGlyph
    * @param  {Object} data
    * @param  {number} position
    * @param  {Function} buildPath
    * @return {opentype.Glyph}
    */
    public static function ttfGlyphLoader(font, index, /* parseGlyph, */data, position/*, buildPath*/) : Void -> Glyph {
        return function() {
            final glyph = new Glyph({index: index/*, font: font*/});
/*
            glyph.path = function() {
                parseGlyph(glyph, data, position);
                final path = buildPath(font.glyphs, glyph);
                path.unitsPerEm = font.unitsPerEm;
                return path;
            };
*/
            //defineDependentProperty(glyph, 'xMin', '_xMin');
            //defineDependentProperty(glyph, 'xMax', '_xMax');
            //defineDependentProperty(glyph, 'yMin', '_yMin');
            //defineDependentProperty(glyph, 'yMax', '_yMax');

            return glyph;
        };
    }
    /**
    * @alias opentype.cffGlyphLoader
    * @param  {opentype.Font} font
    * @param  {number} index
    * @param  {Function} parseCFFCharstring
    * @param  {string} charstring
    * @return {opentype.Glyph}
    */
    public static function cffGlyphLoader(font, index, parseCFFCharstring, charstring) : Void -> Glyph {
        return function() {
            final glyph = new Glyph({index: index/*, font: font*/});

            /*
            glyph.path = function() {
                final path = parseCFFCharstring(font, glyph, charstring);
                path.unitsPerEm = font.unitsPerEm;
                return path;
            };
            */

            return glyph;
        };
    }

}