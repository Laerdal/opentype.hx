package opentype.tables.subtables;

@:structInit
class ClassRangeRecord 
implements IRecord
{
    public function new(
        start : Int,
        end : Int,
        classId : Int
    ) {
        this.start = start;
        this.end = end;
        this.classId = classId;
}
    
    public var start : Int;
    public var end : Int;
    public var classId : Int;
}