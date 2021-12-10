package opentype;

import opentype.tables.Tables;

class Font {
    public function new() {
        tables = new Tables();
        //position = new Position(this);
    }

    public var outlinesFormat : Flavor;
    public var tables(default, null) : Tables;
    //public var position(default, null) : Position;
    public var unitsPerEm : Int;
    public var numGlyphs : Int;
    public var numMetrics : Int;
    public var glyphs : GlyphSet;
    public var _hmtxTableData : Array<HorizontalMetrics>;
    public var kerningPairs : Map<String,Int>;
}

class HorizontalMetrics {
    public function new(advanceWidth, leftSideBearing) {
        this.advanceWidth;
        this.leftSideBearing;
    }
    public var advanceWidth : Int;
    public var leftSideBearing : Int;
}