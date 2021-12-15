package opentype.tables;

import opentype.tables.ILayoutTable;


class Tables {
    public function new() {
        
    }

    public var layoutTables : Map<String, ILayoutTable> = [];

    public var name : String;
    public var cmap : Cmap;
    public var head : Head;
    public var gpos(default,set) : Gpos;
    public var maxp : Maxp;

    function set_gpos(gpos : Gpos) {
        layoutTables["gpos"] = gpos;
        return this.gpos = gpos;
    }
}