package opentype.tables.subtables;

import opentype.tables.ValueRecord;

class Lookup1 
implements ILookup
{
    public function new() {}

    public var posFormat : Int;
    public var coverage : Coverage;
    public var value : ValueRecord;
    public var values : Array<ValueRecord>;
}