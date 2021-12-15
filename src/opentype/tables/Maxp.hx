package opentype.tables;

import haxe.io.Bytes;

class Maxp 
{
// The `maxp` table establishes the memory requirements for the font.
// We need it just to get the number of glyphs in the font.
// https://www.microsoft.com/typography/OTSPEC/maxp.htm
    public var version(default, null) : Float;
    public var numGlyphs(default, null) : Int;
    public var maxPoints(default, null) : Int;
    public var maxContours(default, null) : Int;
    public var maxCompositePoints(default, null) : Int;
    public var maxCompositeContours(default, null) : Int;
    public var maxZones(default, null) : Int;
    public var maxTwilightPoints(default, null) : Int;
    public var maxStorage(default, null) : Int;
    public var maxFunctionDefs(default, null) : Int;
    public var maxInstructionDefs(default, null) : Int;
    public var maxStackElements(default, null) : Int;
    public var maxSizeOfInstructions(default, null) : Int;
    public var maxComponentElements(default, null) : Int;
    public var maxComponentDepth(default, null) : Int;

    public function new() {}

    public static function parse(data : Bytes, position = 0) : Maxp {
        return parseMaxpTable(data, position);
    }

    // Parse the maximum profile `maxp` table.
    static function parseMaxpTable(data, start) {
        final maxp = new Maxp();
        final p = new Parser(data, start);
        maxp.version = p.parseVersion();
        maxp.numGlyphs = p.parseUShort();
        if (maxp.version == 1.0) {
            maxp.maxPoints = p.parseUShort();
            maxp.maxContours = p.parseUShort();
            maxp.maxCompositePoints = p.parseUShort();
            maxp.maxCompositeContours = p.parseUShort();
            maxp.maxZones = p.parseUShort();
            maxp.maxTwilightPoints = p.parseUShort();
            maxp.maxStorage = p.parseUShort();
            maxp.maxFunctionDefs = p.parseUShort();
            maxp.maxInstructionDefs = p.parseUShort();
            maxp.maxStackElements = p.parseUShort();
            maxp.maxSizeOfInstructions = p.parseUShort();
            maxp.maxComponentElements = p.parseUShort();
            maxp.maxComponentDepth = p.parseUShort();
        }
        return maxp;
    }

}