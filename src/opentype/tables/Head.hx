package opentype.tables;

import haxe.io.Bytes;

class Head 
{
    public var version(default, null) : Float;
    public var fontRevision(default, null) : Float;
    public var checkSumAdjustment(default, null) : Int;
    public var magicNumber(default, null) : Int;
    public var flags(default, null) : Int;
    public var unitsPerEm(default, null) : Int;
    public var created(default, null) : Int;
    public var modified(default, null) : Int;
    public var xMin(default, null) : Int;
    public var yMin(default, null) : Int;
    public var xMax(default, null) : Int;
    public var yMax(default, null) : Int;
    public var macStyle(default, null) : Int;
    public var lowestRecPPEM(default, null) : Int;
    public var fontDirectionHint(default, null) : Int;
    public var indexToLocFormat(default, null) : Int;
    public var glyphDataFormat(default, null) : Int;

    public function new() {}

    public static function parse(data : Bytes, position = 0) : Head {
        return parseHeadTable(data, position);
    }
    // Parse the header `head` table
    static function parseHeadTable(data, start) {
        final p = new Parser(data, start);
        final head = new Head();
        head.version = p.parseVersion();
        head.fontRevision = Math.round(p.parseFixed() * 1000) / 1000;
        head.checkSumAdjustment = p.parseULong();
        head.magicNumber = p.parseULong();
        Check.assert(head.magicNumber == 0x5F0F3CF5, 'Font header has wrong magic number.');
        head.flags = p.parseUShort();
        head.unitsPerEm = p.parseUShort();
        head.created = p.parseLongDateTime();
        head.modified = p.parseLongDateTime();
        head.xMin = p.parseShort();
        head.yMin = p.parseShort();
        head.xMax = p.parseShort();
        head.yMax = p.parseShort();
        head.macStyle = p.parseUShort();
        head.lowestRecPPEM = p.parseUShort();
        head.fontDirectionHint = p.parseShort();
        head.indexToLocFormat = p.parseShort();
        head.glyphDataFormat = p.parseShort();
        return head;
    }
}