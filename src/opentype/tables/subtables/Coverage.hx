package opentype.tables.subtables;

@:structInit
class Coverage {
    public function new(
        format : Int,
        ranges : Array<RangeRecord>,
        glyphs : Array<Int>
    
    ) {
        this.format = format;
        this.ranges = ranges;
        this.glyphs = glyphs;
    }

    
    public var format : Int;
    public var ranges : Array<RangeRecord>;
    public var glyphs : Array<Int>;
}