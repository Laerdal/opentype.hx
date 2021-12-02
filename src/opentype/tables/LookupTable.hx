package opentype.tables;

@:structInit
class LookupTable {
    public function new(lookupType : Int, lookupFlag : Int, subTables : Array<Any>) {
        this.lookupType = lookupType;  
        this.lookupFlag = lookupFlag;
        this.subTables = subTables;
    }

    public var lookupType : Int;
    public var lookupFlag : Int;
    public var subTables : Array<Any>;
}