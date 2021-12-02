package opentype.tables.subtables;

@:structInit
class ClassDefinition {
    public function new(
        format : Int,
        ?startGlyphId : Int,
        ?classValueArray : Array<Int>,
        ?classRangeRecords : Array<ClassRangeRecord>
    ) {
        this.format = format;
        this.startGlyphId = startGlyphId != null ? startGlyphId : -1;
        this.classValueArray = classValueArray != null ? classValueArray : [];
        this.classRangeRecords = classRangeRecords != null ? classRangeRecords : [];
    }
    
    public var format : Int;
    public var startGlyphId : Int;
    public var classValueArray : Array<Int>;
    public var classRangeRecords : Array<ClassRangeRecord>;
}