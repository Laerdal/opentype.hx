package opentype.tables.subtables;

import opentype.tables.ValueRecord;

class Lookup 
implements ILookup
{
    public function new() {}

    public var posFormat : Int;
    public var coverage : Coverage;
    public var valueFormat1 : Int;
    public var valueFormat2 : Int;
    public var pairSets : Array<Array<PairSet>>;
    public var classDef1 : ClassDefinition; 
    public var classDef2 : ClassDefinition;
    public var classCount1 : Int;
    public var classCount2 : Int;
    public var classRecords : Array<Array<Pair<ValueRecord, ValueRecord>>>;
    public var value : ValueRecord;
    public var values : Array<ValueRecord>;
}

class PairSet {
    public function new(secondGlyph, value1, value2) {
        this.secondGlyph = secondGlyph;
        this.value1 = value1;
        this.value2 = value2;
    }
    public var secondGlyph : Int;
    public var value1 : ValueRecord;
    public var value2 : ValueRecord;
}