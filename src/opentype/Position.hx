package opentype;

import opentype.tables.LookupTable;

// The Position object provides utility methods to manipulate
// the GPOS position table.
class Position extends Layout {
    var defaultKerningTables : Array<LookupTable>;

    /**
    * @exports opentype.Position
    * @class
    * @extends opentype.Layout
    * @param {opentype.Font}    
    * @constructor
    */
    public function new(font) {
        super(font, 'gpos');
        //Layout.call(this, font, 'gpos');        
    }

    //Position.prototype = Layout.prototype;

    /**
    * Init some data for faster and easier access later.
    */
    public function init() {
        final script = getDefaultScriptName();
        this.defaultKerningTables = getKerningTables(script, null);
    };

    /**
    * Find a glyph pair in a list of lookup tables of type 2 and retrieve the xAdvance kerning value.
    *
    * @param {integer} leftIndex - left glyph index
    * @param {integer} rightIndex - right glyph index
    * @returns {integer}
    */
    public function getKerningValue (kerningLookups : Array<LookupTable>, leftIndex : Int, rightIndex : Int) : Int {
        for (i in 0...kerningLookups.length) {
            final subtables = kerningLookups[i].subTables;
            for (j in 0...subtables.length) {
                final subtable = subtables[j];
                final covIndex = this.getCoverageIndex(subtable.coverage, leftIndex);
                if (covIndex < 0) continue;
                switch (subtable.posFormat) {
                    case 1:
                        // Search Pair Adjustment Positioning Format 1
                        var pairSet = subtable.pairSets[covIndex];
                        for (k in 0...pairSet.length) {
                            var pair = pairSet[k];
                            if (pair.secondGlyph == rightIndex) {
                                return pair.value1 && pair.value1.xAdvance || 0;
                            }
                        }
                        break;      // left glyph found, not right glyph - try next subtable
                    case 2:
                        // Search Pair Adjustment Positioning Format 2
                        final class1 = this.getGlyphClass(subtable.classDef1, leftIndex);
                        final class2 = this.getGlyphClass(subtable.classDef2, rightIndex);
                        final pair = subtable.classRecords[class1][class2];
                        return pair.value1 && pair.value1.xAdvance || 0;
                }
            }
        }
        return 0;
    };

    /**
    * List all kerning lookup tables.
    *
    * @param {string} [script='DFLT'] - use font.position.getDefaultScriptName() for a better default value
    * @param {string} [language='dflt']
    * @return {object[]} The list of kerning lookup tables (may be empty), or undefined if there is no GPOS table (and we should use the kern table)
    */
    public function getKerningTables(script, language) {
        if (font.tables.gpos != null) {
            return getLookupTables(script, language, 'kern', 2, false);
        }
        return null;
    };
}