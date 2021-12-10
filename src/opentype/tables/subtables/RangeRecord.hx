package opentype.tables.subtables;

@:structInit
class RangeRecord
implements IRecord
{
    public function new(
        start : Int,
        end : Int,
        value : Int
    ) {
        this.start = start;
        this.end = end;
        this.value = value;
}
    
    public var start : Int;
    public var end : Int;
    public var value : Int; // Used for startCoverageIndex or class ID;
}