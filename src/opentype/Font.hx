package opentype;

import opentype.tables.Tables;

class Font {
    public function new() {
        tables = new Tables();
    }

    public var outlinesFormat : Flavor;
    public var tables : Tables; 
}