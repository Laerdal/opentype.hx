package opentype.tables.subtables;

@:structInit
class ClassDefinition 
{
    public function new(
        format : Int,
        ?startGlyph : Int,
        ?classes : Array<Int>,
        ?ranges : Array<RangeRecord>
    ) {
        this.format = format;
        this.startGlyph = startGlyph != null ? startGlyph : -1;
        this.classes = classes != null ? classes : [];
        this.ranges = ranges != null ? ranges : [];
    }
    
    public var format : Int;
    public var startGlyph : Int;
    public var classes : Array<Int>;
    public var ranges : Array<RangeRecord>;
}