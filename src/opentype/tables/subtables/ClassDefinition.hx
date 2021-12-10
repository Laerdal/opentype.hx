package opentype.tables.subtables;

@:structInit
class ClassDefinition 
{
    public function new(
        format : Int,
        ?startGlyphId : Int,
        ?classes : Array<Int>,
        ?ranges : Array<RangeRecord>
    ) {
        this.format = format;
        this.startGlyphId = startGlyphId != null ? startGlyphId : -1;
        this.classes = classes != null ? classes : [];
        this.ranges = ranges != null ? ranges : [];
    }
    
    public var format : Int;
    public var startGlyphId : Int;
    public var classes : Array<Int>;
    public var ranges : Array<RangeRecord>;
}