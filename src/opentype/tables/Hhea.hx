package opentype.tables;

import haxe.io.Bytes;

class Hhea {
    public function new() {
        
    }
    
    // Parse the horizontal header `hhea` table
    static public function parse(data : Bytes, position : Int) : Hhea {
        final hhea = new Hhea();
        final p = new Parser(data, position);
        hhea.version = p.parseVersion();
        hhea.ascender = p.parseShort();
        hhea.descender = p.parseShort();
        hhea.lineGap = p.parseShort();
        hhea.advanceWidthMax = p.parseUShort();
        hhea.minLeftSideBearing = p.parseShort();
        hhea.minRightSideBearing = p.parseShort();
        hhea.xMaxExtent = p.parseShort();
        hhea.caretSlopeRise = p.parseShort();
        hhea.caretSlopeRun = p.parseShort();
        hhea.caretOffset = p.parseShort();
        //p.relativeOffset += 8;
        p.skip(8);
        hhea.metricDataFormat = p.parseShort();
        hhea.numberOfHMetrics = p.parseUShort();
        return hhea;
    }    

    public var version(default, null) : Float;
    public var ascender(default, null) : Int;
    public var descender(default, null) : Int;
    public var lineGap(default, null) : Int;
    public var advanceWidthMax(default, null) : Int;
    public var minLeftSideBearing(default, null) : Int;
    public var minRightSideBearing(default, null) : Int;
    public var xMaxExtent(default, null) : Int;
    public var caretSlopeRise(default, null) : Int;
    public var caretSlopeRun(default, null) : Int;
    public var caretOffset(default, null) : Int;
    public var metricDataFormat(default, null) : Int;
    public var numberOfHMetrics(default, null) : Int;
}