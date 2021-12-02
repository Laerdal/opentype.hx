package opentype.tables.subtables;

@:structInit
class RangeRecord {
    public function new(
        startGlyphId : Int,
        endGlyphId : Int,
        startCoverageIndex : Int
    ) {
        this.startGlyphId = startGlyphId;
        this.endGlyphId = endGlyphId;
        this.startCoverageIndex = startCoverageIndex;
}
    
    public var startGlyphId : Int;
    public var endGlyphId : Int;
    public var startCoverageIndex : Int;
}