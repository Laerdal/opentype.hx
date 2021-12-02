package opentype.tables.subtables;

@:structInit
class ClassRangeRecord {
    public function new(
        startGlyphId : Int,
        endGlyphId : Int,
        classId : Int
    ) {
        this.startGlyphId = startGlyphId;
        this.endGlyphId = endGlyphId;
        this.classId = classId;
}
    
    public var startGlyphId : Int;
    public var endGlyphId : Int;
    public var classId : Int;
}