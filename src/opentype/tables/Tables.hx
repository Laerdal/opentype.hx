package opentype.tables;


class Tables {
    public function new() {
        
    }

    public var scriptTables : Map<String, IScriptTable> = [];

    public var name : String;
    public var head : Head;
    public var gpos(default,set) : Gpos;
    public var maxp : Maxp;

    function set_gpos(gpos : Gpos) {
        scriptTables["gpos"] = gpos;
        return this.gpos = gpos;
    }
}