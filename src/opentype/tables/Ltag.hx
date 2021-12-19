package opentype.tables;

import haxe.io.Bytes;
using opentype.BytesHelper;

class Ltag {
    public function new() {
        
    }

    public static function parse(data : Bytes, position = 0) {
        final p = new Parser(data, position);
        final tableVersion = p.parseULong();
        Check.assert(tableVersion == 1, 'Unsupported ltag table version. $tableVersion');
        // The 'ltag' specification does not define any flags; skip the field.
        p.skipULong();
        final numTags = p.parseULong();
    
        final tags = [];
        for (i in 0...numTags) {
            var tag = '';
            final offset = position + p.parseUShort();
            final length = p.parseUShort();
            for (j in offset...offset + length) {
                tag += String.fromCharCode(data.readS8(j));
            }
    
            tags.push(tag);
        }
    
        return tags;
    }    
}